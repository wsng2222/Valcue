import {
  classifyApnsResponse,
  type ApnsSender,
} from "../apns/client.js";
import { RetryableDispatchError } from "../domain/errors.js";
import {
  applyCancel,
  applyUpsert,
  completeDispatch,
  failSession,
  markTaskEnqueued,
  pendingTask,
} from "../domain/session_state.js";
import type {
  ApnsEnvironment,
  CancelScheduleCommand,
  DispatchTaskPayload,
  ScheduleMutationResult,
  SessionRecord,
  UpsertScheduleCommand,
} from "../domain/types.js";
import type { SessionRepository } from "../infrastructure/session_repository.js";
import type { TaskScheduler } from "../infrastructure/task_scheduler.js";

export interface ServiceLogger {
  info(message: string, data?: Record<string, unknown>): void;
  warn(message: string, data?: Record<string, unknown>): void;
  error(message: string, data?: Record<string, unknown>): void;
}

const silentLogger: ServiceLogger = {
  info: () => undefined,
  warn: () => undefined,
  error: () => undefined,
};

export interface LiveActivityScheduleServiceOptions {
  repository: SessionRepository;
  scheduler: TaskScheduler;
  sender?: ApnsSender;
  environment: ApnsEnvironment;
  now?: () => number;
  logger?: ServiceLogger;
}

export class LiveActivityScheduleService {
  readonly #repository: SessionRepository;
  readonly #scheduler: TaskScheduler;
  readonly #sender: ApnsSender | null;
  readonly #environment: ApnsEnvironment;
  readonly #now: () => number;
  readonly #logger: ServiceLogger;

  constructor(options: LiveActivityScheduleServiceOptions) {
    this.#repository = options.repository;
    this.#scheduler = options.scheduler;
    this.#sender = options.sender ?? null;
    this.#environment = options.environment;
    this.#now = options.now ?? Date.now;
    this.#logger = options.logger ?? silentLogger;
  }

  async upsert(
    uid: string,
    command: UpsertScheduleCommand,
  ): Promise<ScheduleMutationResult> {
    const nowMs = this.#now();
    const transition = await this.#repository.transact(
      command.sessionId,
      (current) => {
        const result = applyUpsert(current, uid, command, nowMs);
        return { value: result, next: result.session };
      },
    );

    if (
      transition.scheduleChanged &&
      transition.oldTaskId !== null &&
      transition.oldTaskId !== transition.session.scheduledTaskId
    ) {
      await this.#deleteBestEffort(transition.oldTaskId);
    }
    if (transition.session.enqueuePending) {
      await this.#ensurePendingTask(transition.session);
    }
    return {
      accepted: transition.accepted,
      acceptedRevision: transition.session.scheduleRevision,
      status: transition.session.status,
    };
  }

  async cancel(
    uid: string,
    command: CancelScheduleCommand,
  ): Promise<ScheduleMutationResult> {
    const nowMs = this.#now();
    const transition = await this.#repository.transact(
      command.sessionId,
      (current) => {
        const result = applyCancel(
          current,
          uid,
          command,
          this.#environment,
          nowMs,
        );
        return { value: result, next: result.session };
      },
    );
    if (transition.oldTaskId !== null) {
      await this.#deleteBestEffort(transition.oldTaskId);
    }
    return {
      accepted: transition.accepted,
      acceptedRevision: transition.session.scheduleRevision,
      status: transition.session.status,
    };
  }

  async dispatch(payload: DispatchTaskPayload): Promise<void> {
    const snapshot = await this.#repository.get(payload.sessionId);
    if (snapshot === null || snapshot.tombstone || snapshot.status !== "active") {
      return;
    }
    if (snapshot.scheduleRevision !== payload.scheduleRevision) return;

    if (
      snapshot.nextEventIndex !== payload.eventIndex ||
      snapshot.scheduledTaskId !== payload.taskId ||
      snapshot.events[payload.eventIndex]?.sequence !== payload.sequence
    ) {
      // A prior attempt may have committed progress but failed before enqueueing
      // its successor. Recover that one pending task without re-sending APNs.
      if (snapshot.enqueuePending) await this.#ensurePendingTask(snapshot);
      return;
    }

    const dispatchNowMs = this.#now();
    let dispatchedEventIndex = snapshot.nextEventIndex;
    for (
      let index = snapshot.nextEventIndex + 1;
      index < snapshot.events.length;
      index += 1
    ) {
      const candidate = snapshot.events[index];
      if (candidate === undefined || candidate.deliverAtMs > dispatchNowMs) break;
      dispatchedEventIndex = index;
    }
    const event = snapshot.events[dispatchedEventIndex];
    if (event === undefined) {
      await this.#permanentlyFail(
        snapshot,
        "CorruptEventPointer",
        "Stored event does not match the task payload.",
      );
      return;
    }
    if (
      this.#sender === null ||
      snapshot.token === null ||
      snapshot.activityId === null
    ) {
      await this.#permanentlyFail(
        snapshot,
        "MissingDispatchConfiguration",
        "APNs sender, token, or activity ID is unavailable.",
      );
      return;
    }

    // This is deliberately the token from the last Firestore read immediately
    // before dispatch. Tasks contain no bearer token and cannot restore a stale
    // token after ActivityKit rotates it.
    const apnsTimestampSec = Math.max(
      Math.floor(dispatchNowMs / 1_000),
      snapshot.lastApnsTimestampSec + 1,
    );
    const response = await this.#sender.send({
      environment: snapshot.environment,
      token: snapshot.token,
      sessionId: snapshot.sessionId,
      activityId: snapshot.activityId,
      scheduleRevision: snapshot.scheduleRevision,
      expiresAtMs: snapshot.expiresAtMs,
      event,
      nowMs: dispatchNowMs,
      timestampSec: apnsTimestampSec,
    });
    const disposition = classifyApnsResponse(response);
    if (disposition === "retry") {
      throw new RetryableDispatchError(
        `APNs returned retryable status ${response.status}.`,
      );
    }
    if (disposition === "invalid_token") {
      const failure = await this.#failIfCurrent(
        snapshot,
        "invalid_token",
        `APNS_${response.status}`,
        response.reason ?? "InvalidActivityToken",
      );
      if (failure === "superseded_token") {
        // The APNs response belongs to a token that rotated while the request
        // was in flight. Keep the current task alive so its retry reads and
        // sends to the replacement token.
        throw new RetryableDispatchError(
          "Ignoring APNs failure for a superseded ActivityKit token.",
        );
      }
      return;
    }
    if (disposition === "permanent_failure") {
      const failure = await this.#failIfCurrent(
        snapshot,
        "failed",
        `APNS_${response.status}`,
        response.reason ?? "PermanentApnsFailure",
      );
      if (failure === "superseded_token") {
        throw new RetryableDispatchError(
          "Ignoring APNs failure for a superseded ActivityKit token.",
        );
      }
      return;
    }

    const completion = await this.#repository.transact(
      payload.sessionId,
      (current) => {
        if (current === null) return { value: null, next: null };
        if (
          current.scheduleRevision !== payload.scheduleRevision ||
          current.nextEventIndex !== payload.eventIndex ||
          current.scheduledTaskId !== payload.taskId
        ) {
          return { value: null, next: null };
        }
        const result = completeDispatch(
          current,
          payload.scheduleRevision,
          payload.eventIndex,
          dispatchedEventIndex,
          event.sequence,
          apnsTimestampSec,
          this.#now(),
        );
        return { value: result, next: result.session };
      },
    );
    if (completion !== null && completion.nextTask !== null) {
      await this.#ensurePendingTask(completion.session);
    }
  }

  async #ensurePendingTask(session: SessionRecord): Promise<void> {
    const plan = pendingTask(session);
    if (plan === null) return;
    await this.#scheduler.enqueue(plan);
    await this.#repository.transact(session.sessionId, (current) => {
      if (current === null) return { value: undefined, next: null };
      const next = markTaskEnqueued(
        current,
        session.scheduleRevision,
        plan.taskId,
        this.#now(),
      );
      return {
        value: undefined,
        next: next === current ? null : next,
      };
    });
  }

  async #deleteBestEffort(taskId: string): Promise<void> {
    try {
      await this.#scheduler.delete(taskId);
    } catch (error) {
      this.#logger.warn("Unable to delete stale Live Activity task.", {
        taskId,
        error: error instanceof Error ? error.name : "UnknownError",
      });
    }
  }

  async #permanentlyFail(
    snapshot: SessionRecord,
    code: string,
    reason: string,
  ): Promise<void> {
    await this.#failIfCurrent(snapshot, "failed", code, reason);
  }

  async #failIfCurrent(
    snapshot: SessionRecord,
    status: "invalid_token" | "failed",
    code: string,
    reason: string,
  ): Promise<"applied" | "superseded_token" | "stale"> {
    const result = await this.#repository.transact(
      snapshot.sessionId,
      (current) => {
        if (
          current === null ||
          current.scheduleRevision !== snapshot.scheduleRevision ||
          current.nextEventIndex !== snapshot.nextEventIndex ||
          current.scheduledTaskId !== snapshot.scheduledTaskId ||
          current.tombstone
        ) {
          return { value: "stale" as const, next: null };
        }
        if (
          current.tokenVersion !== snapshot.tokenVersion ||
          current.tokenHash !== snapshot.tokenHash
        ) {
          return { value: "superseded_token" as const, next: null };
        }
        const nowMs = this.#now();
        return {
          value: "applied" as const,
          next: failSession(
            current,
            status,
            { code, reason: reason.slice(0, 160), atMs: nowMs },
            nowMs,
          ),
        };
      },
    );
    if (result !== "applied") {
      if (result === "superseded_token") {
        this.#logger.info("Ignored APNs failure for a rotated token.", {
          scheduleRevision: snapshot.scheduleRevision,
          tokenVersion: snapshot.tokenVersion,
        });
      }
      return result;
    }
    this.#logger.error("Live Activity session stopped after APNs failure.", {
      tokenHashPrefix: snapshot.tokenHash?.slice(0, 16) ?? "redacted",
      status,
      code,
    });
    return result;
  }
}
