import { describe, expect, it } from "vitest";

import { DomainError } from "../src/domain/errors.js";
import {
  validateCancelSchedule,
  validateUpsertSchedule,
} from "../src/domain/validation.js";
import {
  NOW_MS,
  rawCancel,
  rawLongRunningUpsert,
  rawUpsert,
} from "./helpers.js";

describe("schedule validation", () => {
  it("normalizes the canonical client upsert and strips extra content keys", () => {
    const command = validateUpsertSchedule(rawUpsert(), NOW_MS, "sandbox");

    expect(command.events).toHaveLength(3);
    expect(command.events[0]?.contentState).not.toHaveProperty("routineId");
    expect(command.events[0]?.staleAtMs).toBe(NOW_MS + 2 * 60_000);
    expect(command.events[2]?.action).toBe("end");
    expect(command.eventDigest).toMatch(/^[0-9a-f]{64}$/);
  });

  it("accepts the coordinator's canonical cancellation reasons", () => {
    for (const reason of [
      "paused",
      "finished",
      "stopped",
      "featureDisabled",
      "premiumRevoked",
      "disposed",
      "staleSession",
    ]) {
      expect(validateCancelSchedule(rawCancel({ reason }), NOW_MS).reason).toBe(
        reason,
      );
    }
  });

  it("rejects a deployment environment mismatch", () => {
    expect(() =>
      validateUpsertSchedule(rawUpsert(), NOW_MS, "production"),
    ).toThrowError(DomainError);
  });

  it("rejects unordered events and schedules beyond eight hours", () => {
    const unordered = rawUpsert();
    const events = unordered.events as Array<Record<string, unknown>>;
    events[1] = { ...events[1], deliverAtMs: NOW_MS + 30_000 };
    expect(() =>
      validateUpsertSchedule(unordered, NOW_MS, "sandbox"),
    ).toThrow(/strictly increasing/);

    const distant = rawUpsert();
    const distantEvents = distant.events as Array<Record<string, unknown>>;
    distantEvents[2] = {
      ...distantEvents[2],
      deliverAtMs: NOW_MS + 8 * 60 * 60 * 1_000 + 1,
      dismissalAtMs: NOW_MS + 8 * 60 * 60 * 1_000 + 2,
    };
    distant.expiresAtMs = NOW_MS + 9 * 60 * 60 * 1_000;
    expect(() =>
      validateUpsertSchedule(distant, NOW_MS, "sandbox"),
    ).toThrow(/eight-hour/);
  });

  it("accepts unexpired schedules with old boundaries for delayed token rotation", () => {
    const twentyMinutesLater = NOW_MS + 20 * 60_000;
    const command = validateUpsertSchedule(
      rawLongRunningUpsert(),
      twentyMinutesLater,
      "sandbox",
    );

    expect(command.generatedAtMs).toBe(NOW_MS);
    expect(command.events[0]!.deliverAtMs).toBeLessThan(twentyMinutesLater);
    expect(command.events[1]!.deliverAtMs).toBeLessThan(twentyMinutesLater);
    expect(command.events[2]!.deliverAtMs).toBeGreaterThan(twentyMinutesLater);
  });

  it("still rejects schedules generated outside the eight-hour horizon", () => {
    const moreThanEightHoursLater = NOW_MS + 8 * 60 * 60 * 1_000 + 1;
    const stale = rawLongRunningUpsert();
    stale.expiresAtMs = moreThanEightHoursLater + 60_000;

    expect(() =>
      validateUpsertSchedule(stale, moreThanEightHoursLater, "sandbox"),
    ).toThrow(/eight-hour activity horizon/);
  });

  it("requires one final end event and enforces the 56-event cap", () => {
    const missingEnd = rawUpsert();
    const events = missingEnd.events as Array<Record<string, unknown>>;
    events[2] = { ...events[2], action: "update", dismissalAtMs: undefined };
    expect(() =>
      validateUpsertSchedule(missingEnd, NOW_MS, "sandbox"),
    ).toThrow(/exactly one final end/);

    const oversized = rawUpsert();
    oversized.events = Array.from({ length: 57 }, (_, index) => ({
      sequence: index,
      deliverAtMs: NOW_MS + (index + 1) * 1_000,
      action: index === 56 ? "end" : "update",
      contentState: (rawUpsert().events as Array<Record<string, unknown>>)[
        index === 56 ? 2 : 0
      ]?.contentState,
    }));
    expect(() =>
      validateUpsertSchedule(oversized, NOW_MS, "sandbox"),
    ).toThrow(/1-56/);
  });
});
