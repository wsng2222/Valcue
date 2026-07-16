import { DomainError } from "./errors.js";
import { makeTaskPlan, sha256Hex } from "./task_ids.js";
import type {
  CancelScheduleCommand,
  SessionErrorRecord,
  SessionRecord,
  TaskPlan,
  UpsertScheduleCommand,
} from "./types.js";
import { LIVE_ACTIVITY_SCHEMA_VERSION } from "./types.js";

const TOMBSTONE_RETENTION_MS = 24 * 60 * 60 * 1_000;

function isResumableCancellation(command: CancelScheduleCommand): boolean {
  return command.reason === "paused";
}

export interface UpsertTransition {
  session: SessionRecord;
  oldTaskId: string | null;
  scheduleChanged: boolean;
  tokenChanged: boolean;
  accepted: boolean;
}

export interface CancelTransition {
  session: SessionRecord;
  oldTaskId: string | null;
  accepted: boolean;
}

export interface DispatchCompletion {
  session: SessionRecord;
  nextTask: TaskPlan | null;
}

function assertOwner(session: SessionRecord, uid: string): void {
  if (session.uid !== uid) {
    // Do not reveal whether another user's opaque session ID exists.
    throw new DomainError("not-found", "Live Activity schedule not found.");
  }
}

function tokenHash(token: string): string {
  return sha256Hex(token);
}

function initialTask(session: {
  sessionId: string;
  scheduleRevision: number;
  events: SessionRecord["events"];
}): TaskPlan {
  const first = session.events[0];
  if (first === undefined) {
    throw new DomainError("invalid-argument", "A schedule requires events.");
  }
  return makeTaskPlan(session.sessionId, session.scheduleRevision, 0, first);
}

export function applyUpsert(
  existing: SessionRecord | null,
  uid: string,
  command: UpsertScheduleCommand,
  nowMs: number,
): UpsertTransition {
  const incomingTokenHash = tokenHash(command.token);

  if (existing === null) {
    const plan = initialTask(command);
    const session: SessionRecord = {
      schemaVersion: LIVE_ACTIVITY_SCHEMA_VERSION,
      sessionId: command.sessionId,
      uid,
      activityId: command.activityId,
      token: command.token,
      tokenHash: incomingTokenHash,
      environment: command.environment,
      tokenVersion: command.tokenVersion,
      scheduleRevision: command.scheduleRevision,
      fingerprint: command.fingerprint,
      eventDigest: command.eventDigest,
      generatedAtMs: command.generatedAtMs,
      expiresAtMs: command.expiresAtMs,
      events: command.events,
      nextEventIndex: 0,
      scheduledTaskId: plan.taskId,
      enqueuePending: true,
      lastDispatchedSequence: null,
      lastApnsTimestampSec: 0,
      status: "active",
      tombstone: false,
      lastError: null,
      createdAtMs: nowMs,
      updatedAtMs: nowMs,
    };
    return {
      session,
      oldTaskId: null,
      scheduleChanged: true,
      tokenChanged: true,
      accepted: true,
    };
  }

  assertOwner(existing, uid);
  if (existing.tombstone) {
    return {
      session: existing,
      oldTaskId: null,
      scheduleChanged: false,
      tokenChanged: false,
      accepted: false,
    };
  }
  if (
    (existing.activityId !== null &&
      existing.activityId !== command.activityId) ||
    existing.environment !== command.environment
  ) {
    throw new DomainError(
      "failed-precondition",
      "activityId and environment are immutable for a session.",
    );
  }
  if (command.scheduleRevision < existing.scheduleRevision) {
    return {
      session: existing,
      oldTaskId: null,
      scheduleChanged: false,
      tokenChanged: false,
      accepted: false,
    };
  }

  if (command.scheduleRevision === existing.scheduleRevision) {
    if (
      command.fingerprint !== existing.fingerprint ||
      command.eventDigest !== existing.eventDigest
    ) {
      return {
        session: existing,
        oldTaskId: null,
        scheduleChanged: false,
        tokenChanged: false,
        accepted: false,
      };
    }
    if (command.tokenVersion < existing.tokenVersion) {
      // An out-of-order retry must never restore an older ActivityKit token.
      return {
        session: existing,
        oldTaskId: null,
        scheduleChanged: false,
        tokenChanged: false,
        accepted: true,
      };
    }
    if (
      command.tokenVersion === existing.tokenVersion &&
      incomingTokenHash !== existing.tokenHash
    ) {
      throw new DomainError(
        "already-exists",
        "tokenVersion already exists with a different token.",
      );
    }
    if (command.tokenVersion === existing.tokenVersion) {
      return {
        session: existing,
        oldTaskId: null,
        scheduleChanged: false,
        tokenChanged: false,
        accepted: true,
      };
    }
    const session: SessionRecord = {
      ...existing,
      token: command.token,
      tokenHash: incomingTokenHash,
      tokenVersion: command.tokenVersion,
      updatedAtMs: nowMs,
    };
    return {
      session,
      oldTaskId: null,
      scheduleChanged: false,
      tokenChanged: true,
      accepted: true,
    };
  }

  let nextToken = existing.token;
  let nextTokenHash = existing.tokenHash;
  let nextTokenVersion = existing.tokenVersion;
  let tokenChanged = false;
  if (existing.token === null) {
    if (command.tokenVersion < existing.tokenVersion) {
      // A paused session deliberately drops its bearer token. It may resume
      // with the same token version (verified by its retained hash), but an
      // older token must never reactivate dispatch.
      return {
        session: existing,
        oldTaskId: null,
        scheduleChanged: false,
        tokenChanged: false,
        accepted: false,
      };
    }
    if (
      command.tokenVersion === existing.tokenVersion &&
      existing.tokenHash !== null &&
      incomingTokenHash !== existing.tokenHash
    ) {
      throw new DomainError(
        "already-exists",
        "tokenVersion already exists with a different token.",
      );
    }
    nextToken = command.token;
    nextTokenHash = incomingTokenHash;
    nextTokenVersion = command.tokenVersion;
    tokenChanged = true;
  } else if (command.tokenVersion > existing.tokenVersion) {
    nextToken = command.token;
    nextTokenHash = incomingTokenHash;
    nextTokenVersion = command.tokenVersion;
    tokenChanged = true;
  } else if (
    command.tokenVersion === existing.tokenVersion &&
    incomingTokenHash !== existing.tokenHash
  ) {
    throw new DomainError(
      "already-exists",
      "tokenVersion already exists with a different token.",
    );
  }

  const plan = initialTask(command);
  const session: SessionRecord = {
    ...existing,
    activityId: command.activityId,
    token: nextToken,
    tokenHash: nextTokenHash,
    tokenVersion: nextTokenVersion,
    scheduleRevision: command.scheduleRevision,
    fingerprint: command.fingerprint,
    eventDigest: command.eventDigest,
    generatedAtMs: command.generatedAtMs,
    expiresAtMs: command.expiresAtMs,
    events: command.events,
    nextEventIndex: 0,
    scheduledTaskId: plan.taskId,
    enqueuePending: true,
    lastDispatchedSequence: null,
    status: "active",
    lastError: null,
    updatedAtMs: nowMs,
  };
  return {
    session,
    oldTaskId: existing.scheduledTaskId,
    scheduleChanged: true,
    tokenChanged,
    accepted: true,
  };
}

export function applyCancel(
  existing: SessionRecord | null,
  uid: string,
  command: CancelScheduleCommand,
  environment: SessionRecord["environment"],
  nowMs: number,
): CancelTransition {
  const cancellationFingerprint = `cancel:${command.reason}:${command.scheduleRevision}`;
  const resumable = isResumableCancellation(command);
  if (existing === null) {
    return {
      session: {
        schemaVersion: LIVE_ACTIVITY_SCHEMA_VERSION,
        sessionId: command.sessionId,
        uid,
        activityId: command.activityId,
        token: null,
        tokenHash: null,
        environment,
        tokenVersion: 0,
        scheduleRevision: command.scheduleRevision,
        fingerprint: cancellationFingerprint,
        eventDigest: "",
        generatedAtMs: command.canceledAtMs,
        expiresAtMs: nowMs + TOMBSTONE_RETENTION_MS,
        events: [],
        nextEventIndex: 0,
        scheduledTaskId: null,
        enqueuePending: false,
        lastDispatchedSequence: null,
        lastApnsTimestampSec: 0,
        status: resumable ? "paused" : "cancelled",
        tombstone: !resumable,
        lastError: null,
        createdAtMs: nowMs,
        updatedAtMs: nowMs,
      },
      oldTaskId: null,
      accepted: true,
    };
  }

  assertOwner(existing, uid);
  if (existing.tombstone) {
    if (command.scheduleRevision < existing.scheduleRevision) {
      return { session: existing, oldTaskId: null, accepted: false };
    }
    if (command.scheduleRevision === existing.scheduleRevision) {
      return { session: existing, oldTaskId: null, accepted: true };
    }
    return {
      session: {
        ...existing,
        scheduleRevision: command.scheduleRevision,
        fingerprint: cancellationFingerprint,
        generatedAtMs: command.canceledAtMs,
        updatedAtMs: nowMs,
      },
      oldTaskId: null,
      accepted: true,
    };
  }
  if (
    command.activityId !== null &&
    existing.activityId !== null &&
    command.activityId !== existing.activityId
  ) {
    return { session: existing, oldTaskId: null, accepted: false };
  }
  if (command.scheduleRevision < existing.scheduleRevision) {
    return { session: existing, oldTaskId: null, accepted: false };
  }
  if (resumable) {
    return {
      session: {
        ...existing,
        // Do not retain the bearer token while no remote work is scheduled.
        // Keep only its hash/version so the same ActivityKit registration can
        // safely be supplied again when a higher revision resumes the workout.
        token: null,
        scheduleRevision: command.scheduleRevision,
        fingerprint: cancellationFingerprint,
        eventDigest: "",
        generatedAtMs: command.canceledAtMs,
        expiresAtMs: nowMs + TOMBSTONE_RETENTION_MS,
        events: [],
        nextEventIndex: 0,
        scheduledTaskId: null,
        enqueuePending: false,
        status: "paused",
        tombstone: false,
        lastError: null,
        updatedAtMs: nowMs,
      },
      oldTaskId: existing.scheduledTaskId,
      accepted: true,
    };
  }
  return {
    session: {
      ...existing,
      token: null,
      tokenHash: null,
      scheduleRevision: command.scheduleRevision,
      fingerprint: cancellationFingerprint,
      generatedAtMs: command.canceledAtMs,
      expiresAtMs: nowMs + TOMBSTONE_RETENTION_MS,
      events: [],
      nextEventIndex: 0,
      scheduledTaskId: null,
      enqueuePending: false,
      status: "cancelled",
      tombstone: true,
      updatedAtMs: nowMs,
    },
    oldTaskId: existing.scheduledTaskId,
    accepted: true,
  };
}

export function pendingTask(session: SessionRecord): TaskPlan | null {
  if (
    session.tombstone ||
    session.status !== "active" ||
    session.scheduledTaskId === null
  ) {
    return null;
  }
  const event = session.events[session.nextEventIndex];
  if (event === undefined) return null;
  const plan = makeTaskPlan(
    session.sessionId,
    session.scheduleRevision,
    session.nextEventIndex,
    event,
  );
  if (plan.taskId !== session.scheduledTaskId) {
    throw new DomainError("internal", "Stored task pointer is inconsistent.");
  }
  return plan;
}

export function markTaskEnqueued(
  existing: SessionRecord,
  scheduleRevision: number,
  taskId: string,
  nowMs: number,
): SessionRecord {
  if (
    existing.scheduleRevision !== scheduleRevision ||
    existing.scheduledTaskId !== taskId ||
    existing.tombstone
  ) {
    return existing;
  }
  return { ...existing, enqueuePending: false, updatedAtMs: nowMs };
}

export function completeDispatch(
  existing: SessionRecord,
  scheduleRevision: number,
  expectedEventIndex: number,
  dispatchedEventIndex: number,
  sequence: number,
  apnsTimestampSec: number,
  nowMs: number,
): DispatchCompletion {
  if (
    existing.tombstone ||
    existing.status !== "active" ||
    existing.scheduleRevision !== scheduleRevision ||
    existing.nextEventIndex !== expectedEventIndex
  ) {
    return { session: existing, nextTask: null };
  }
  const event = existing.events[dispatchedEventIndex];
  if (event === undefined || event.sequence !== sequence) {
    throw new DomainError("internal", "Stored event pointer is inconsistent.");
  }

  if (event.action === "end") {
    return {
      session: {
        ...existing,
        token: null,
        tokenHash: null,
        nextEventIndex: dispatchedEventIndex + 1,
        scheduledTaskId: null,
        enqueuePending: false,
        lastDispatchedSequence: sequence,
        lastApnsTimestampSec: apnsTimestampSec,
        status: "ended",
        tombstone: true,
        expiresAtMs: nowMs + TOMBSTONE_RETENTION_MS,
        updatedAtMs: nowMs,
      },
      nextTask: null,
    };
  }

  const nextIndex = dispatchedEventIndex + 1;
  const nextEvent = existing.events[nextIndex];
  if (nextEvent === undefined) {
    throw new DomainError("internal", "An update event is missing a successor.");
  }
  const nextTask = makeTaskPlan(
    existing.sessionId,
    existing.scheduleRevision,
    nextIndex,
    nextEvent,
  );
  return {
    session: {
      ...existing,
      nextEventIndex: nextIndex,
      scheduledTaskId: nextTask.taskId,
      enqueuePending: true,
      lastDispatchedSequence: sequence,
      lastApnsTimestampSec: apnsTimestampSec,
      updatedAtMs: nowMs,
    },
    nextTask,
  };
}

export function failSession(
  existing: SessionRecord,
  status: "invalid_token" | "failed",
  error: SessionErrorRecord,
  nowMs: number,
): SessionRecord {
  return {
    ...existing,
    token: null,
    tokenHash: null,
    scheduledTaskId: null,
    enqueuePending: false,
    status,
    tombstone: true,
    lastError: error,
    expiresAtMs: nowMs + TOMBSTONE_RETENTION_MS,
    updatedAtMs: nowMs,
  };
}
