import { describe, expect, it } from "vitest";

import { validateCancelSchedule, validateUpsertSchedule } from "../src/domain/validation.js";
import { LiveActivityScheduleService } from "../src/service/live_activity_schedule_service.js";
import {
  FakeApnsSender,
  FakeTaskScheduler,
  InMemorySessionRepository,
  NOW_MS,
  rawCancel,
  rawLongRunningUpsert,
  rawUpsert,
} from "./helpers.js";

function harness(initialNow = NOW_MS) {
  const repository = new InMemorySessionRepository();
  const scheduler = new FakeTaskScheduler();
  const sender = new FakeApnsSender();
  let nowMs = initialNow;
  const service = new LiveActivityScheduleService({
    repository,
    scheduler,
    sender,
    environment: "sandbox",
    now: () => nowMs,
  });
  return {
    repository,
    scheduler,
    sender,
    service,
    setNow(value: number) {
      nowMs = value;
    },
  };
}

function command(raw: Record<string, unknown> = rawUpsert()) {
  return validateUpsertSchedule(raw, NOW_MS, "sandbox");
}

describe("LiveActivityScheduleService", () => {
  it("enqueues only the next event and treats an identical upsert as idempotent", async () => {
    const subject = harness();
    const first = await subject.service.upsert("uid-1", command());
    const second = await subject.service.upsert("uid-1", command());

    expect(first).toMatchObject({ accepted: true, acceptedRevision: 1 });
    expect(second).toMatchObject({ accepted: true, acceptedRevision: 1 });
    expect(subject.scheduler.enqueued).toHaveLength(1);
    expect(subject.scheduler.enqueued[0]?.payload.eventIndex).toBe(0);
    expect(
      subject.repository.records.get(command().sessionId)?.enqueuePending,
    ).toBe(false);
  });

  it("uses the latest tokenVersion without replacing the current task", async () => {
    const subject = harness();
    const initial = command();
    await subject.service.upsert("uid-1", initial);

    const rotated = command(
      rawUpsert({ tokenVersion: 2, token: "cd".repeat(32) }),
    );
    const result = await subject.service.upsert("uid-1", rotated);

    expect(result.accepted).toBe(true);
    expect(subject.scheduler.enqueued).toHaveLength(1);
    expect(subject.repository.records.get(initial.sessionId)?.tokenVersion).toBe(2);

    subject.setNow(NOW_MS + 60_000);
    await subject.service.dispatch(subject.scheduler.enqueued[0]!.payload);
    expect(subject.sender.requests[0]?.token).toBe("cd".repeat(32));
  });

  it("does not tombstone a rotated token when an in-flight old token returns 410", async () => {
    const subject = harness();
    const initial = command();
    await subject.service.upsert("uid-1", initial);
    const currentTask = subject.scheduler.enqueued[0]!;
    const rotated = command(
      rawUpsert({ tokenVersion: 2, token: "cd".repeat(32) }),
    );
    subject.sender.response = {
      status: 410,
      reason: "Unregistered",
      apnsId: null,
    };
    subject.sender.beforeResponse = async () => {
      await subject.service.upsert("uid-1", rotated);
    };
    subject.setNow(NOW_MS + 60_000);

    await expect(subject.service.dispatch(currentTask.payload)).rejects.toThrow(
      /superseded ActivityKit token/,
    );

    expect(subject.repository.records.get(initial.sessionId)).toMatchObject({
      token: "cd".repeat(32),
      tokenVersion: 2,
      scheduledTaskId: currentTask.taskId,
      status: "active",
      tombstone: false,
    });

    // Emulate the Cloud Tasks retry. It must re-read Firestore and send to the
    // replacement token rather than replaying the old bearer token.
    subject.sender.response = { status: 200, reason: null, apnsId: null };
    await subject.service.dispatch(currentTask.payload);

    expect(subject.sender.requests).toHaveLength(2);
    expect(subject.sender.requests[0]?.token).toBe("ab".repeat(32));
    expect(subject.sender.requests[1]?.token).toBe("cd".repeat(32));
    expect(subject.repository.records.get(initial.sessionId)).toMatchObject({
      nextEventIndex: 1,
      status: "active",
      tombstone: false,
    });
  });

  it("accepts a same-schedule token rotation more than fifteen minutes later", async () => {
    const subject = harness();
    const initial = validateUpsertSchedule(
      rawLongRunningUpsert(),
      NOW_MS,
      "sandbox",
    );
    await subject.service.upsert("uid-1", initial);

    const twentyMinutesLater = NOW_MS + 20 * 60_000;
    subject.setNow(twentyMinutesLater);
    const rotated = validateUpsertSchedule(
      rawLongRunningUpsert({ tokenVersion: 2, token: "cd".repeat(32) }),
      twentyMinutesLater,
      "sandbox",
    );
    const result = await subject.service.upsert("uid-1", rotated);

    expect(result).toMatchObject({ accepted: true, acceptedRevision: 1 });
    expect(subject.repository.records.get(initial.sessionId)).toMatchObject({
      token: "cd".repeat(32),
      tokenVersion: 2,
    });
    expect(subject.scheduler.enqueued).toHaveLength(1);
  });

  it("returns an ignored acknowledgement for a stale schedule revision", async () => {
    const subject = harness();
    await subject.service.upsert(
      "uid-1",
      command(rawUpsert({ revision: 3, fingerprint: "c".repeat(64) })),
    );
    const stale = await subject.service.upsert(
      "uid-1",
      command(rawUpsert({ revision: 2, fingerprint: "b".repeat(64) })),
    );

    expect(stale).toMatchObject({ accepted: false, acceptedRevision: 3 });
    expect(subject.scheduler.enqueued).toHaveLength(1);
  });

  it("coalesces delayed boundaries to the latest due event and then schedules one successor", async () => {
    const subject = harness();
    const upsert = command();
    await subject.service.upsert("uid-1", upsert);
    const firstTask = subject.scheduler.enqueued[0]!;

    subject.setNow(NOW_MS + 2 * 60_000 + 500);
    await subject.service.dispatch(firstTask.payload);

    expect(subject.sender.requests).toHaveLength(1);
    expect(subject.sender.requests[0]?.event.sequence).toBe(1);
    expect(subject.scheduler.enqueued).toHaveLength(2);
    expect(subject.scheduler.enqueued[1]?.payload.eventIndex).toBe(2);
    const stored = subject.repository.records.get(upsert.sessionId);
    expect(stored?.nextEventIndex).toBe(2);
    expect(stored?.lastDispatchedSequence).toBe(1);
  });

  it("prioritizes a due final end and does not replay older updates", async () => {
    const subject = harness();
    const upsert = command();
    await subject.service.upsert("uid-1", upsert);

    subject.setNow(NOW_MS + 4 * 60_000);
    await subject.service.dispatch(subject.scheduler.enqueued[0]!.payload);

    expect(subject.sender.requests).toHaveLength(1);
    expect(subject.sender.requests[0]?.event.action).toBe("end");
    expect(subject.repository.records.get(upsert.sessionId)).toMatchObject({
      status: "ended",
      tombstone: true,
    });
    expect(subject.scheduler.enqueued).toHaveLength(1);
  });

  it("keeps APNs timestamps strictly increasing across same-second logical updates", async () => {
    const subject = harness();
    const upsert = command();
    await subject.service.upsert("uid-1", upsert);

    subject.setNow(NOW_MS + 60_000);
    await subject.service.dispatch(subject.scheduler.enqueued[0]!.payload);
    const nextTask = subject.scheduler.enqueued[1]!;
    // Simulate an immediate retry/accelerated test delivery in the same second.
    subject.setNow(NOW_MS + 60_000);
    await subject.service.dispatch(nextTask.payload);

    expect(subject.sender.requests).toHaveLength(2);
    expect(subject.sender.requests[1]!.timestampSec).toBeGreaterThan(
      subject.sender.requests[0]!.timestampSec,
    );
  });

  it("recovers a successor enqueue failure without sending the prior event twice", async () => {
    const subject = harness();
    await subject.service.upsert("uid-1", command());
    const firstTask = subject.scheduler.enqueued[0]!;
    subject.scheduler.failNextEnqueue = true;
    subject.setNow(NOW_MS + 60_000);

    await expect(subject.service.dispatch(firstTask.payload)).rejects.toThrow(
      /synthetic enqueue failure/,
    );
    expect(subject.sender.requests).toHaveLength(1);
    expect(
      subject.repository.records.get(command().sessionId)?.enqueuePending,
    ).toBe(true);

    await subject.service.dispatch(firstTask.payload);
    expect(subject.sender.requests).toHaveLength(1);
    expect(subject.scheduler.enqueued).toHaveLength(2);
  });

  it("pauses without a tombstone, ignores stale tasks, and accepts a higher-revision resume", async () => {
    const subject = harness();
    const upsert = command();
    await subject.service.upsert("uid-1", upsert);
    const staleTask = subject.scheduler.enqueued[0]!;
    const cancellation = validateCancelSchedule(
      rawCancel({ revision: 2, reason: "paused" }),
      NOW_MS,
    );

    const ack = await subject.service.cancel("uid-1", cancellation);
    await subject.service.dispatch(staleTask.payload);

    expect(ack).toMatchObject({ accepted: true, acceptedRevision: 2 });
    expect(subject.sender.requests).toHaveLength(0);
    expect(subject.repository.records.get(upsert.sessionId)).toMatchObject({
      token: null,
      tombstone: false,
      status: "paused",
      fingerprint: "cancel:paused:2",
    });

    const resumed = await subject.service.upsert(
      "uid-1",
      command(rawUpsert({ revision: 3, fingerprint: "d".repeat(64) })),
    );
    expect(resumed).toMatchObject({ accepted: true, acceptedRevision: 3 });
    expect(subject.repository.records.get(upsert.sessionId)).toMatchObject({
      token: "ab".repeat(32),
      tombstone: false,
      status: "active",
    });
    expect(subject.scheduler.enqueued).toHaveLength(2);
  });

  it("binds activity identity when pause arrives before registration", async () => {
    const subject = harness();
    const pause = validateCancelSchedule(
      rawCancel({ revision: 1, reason: "paused", activityId: null }),
      NOW_MS,
    );

    await subject.service.cancel("uid-1", pause);
    const resumed = await subject.service.upsert(
      "uid-1",
      command(rawUpsert({ revision: 2, fingerprint: "b".repeat(64) })),
    );

    expect(resumed).toMatchObject({ accepted: true, acceptedRevision: 2 });
    expect(subject.repository.records.get(command().sessionId)).toMatchObject({
      activityId: "activity-1",
      status: "active",
      tombstone: false,
    });
  });

  it("keeps terminal cancellations tombstoned", async () => {
    const subject = harness();
    await subject.service.upsert("uid-1", command());
    const stop = validateCancelSchedule(
      rawCancel({ revision: 2, reason: "stopped" }),
      NOW_MS,
    );

    await subject.service.cancel("uid-1", stop);
    const resurrection = await subject.service.upsert(
      "uid-1",
      command(rawUpsert({ revision: 3, fingerprint: "d".repeat(64) })),
    );

    expect(subject.repository.records.get(command().sessionId)).toMatchObject({
      status: "cancelled",
      tombstone: true,
    });
    expect(resurrection).toMatchObject({ accepted: false, acceptedRevision: 2 });
  });

  it("recovers an ambiguous initial enqueue through an identical retry", async () => {
    const subject = harness();
    subject.scheduler.failNextEnqueue = true;
    const upsert = command();

    await expect(subject.service.upsert("uid-1", upsert)).rejects.toThrow(
      /synthetic enqueue failure/,
    );
    expect(subject.repository.records.get(upsert.sessionId)?.enqueuePending).toBe(
      true,
    );

    const retry = await subject.service.upsert("uid-1", upsert);
    expect(retry.accepted).toBe(true);
    expect(subject.scheduler.enqueued).toHaveLength(1);
    expect(subject.repository.records.get(upsert.sessionId)?.enqueuePending).toBe(
      false,
    );
  });
});
