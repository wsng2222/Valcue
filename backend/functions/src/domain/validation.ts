import { createHash } from "node:crypto";

import { activityKitPayloadBytes } from "../apns/payload.js";
import { DomainError } from "./errors.js";
import type {
  ApnsEnvironment,
  CancelReason,
  CancelScheduleCommand,
  DispatchTaskPayload,
  LiveActivityContentState,
  ScheduleAction,
  ScheduleEvent,
  UpsertScheduleCommand,
} from "./types.js";
import {
  LIVE_ACTIVITY_SCHEMA_VERSION,
  MAX_SCHEDULE_EVENTS,
} from "./types.js";

const MAX_CLOCK_SKEW_MS = 2 * 60 * 1_000;
const MAX_ACTIVITY_HORIZON_MS = 8 * 60 * 60 * 1_000;
const MAX_SESSION_LIFETIME_MS = 12 * 60 * 60 * 1_000;
const MAX_APNS_PAYLOAD_BYTES = 4_096;

type JsonObject = Record<string, unknown>;

function invalid(message: string): never {
  throw new DomainError("invalid-argument", message);
}

function object(value: unknown, name: string): JsonObject {
  if (value === null || typeof value !== "object" || Array.isArray(value)) {
    invalid(`${name} must be an object.`);
  }
  return value as JsonObject;
}

function string(
  value: unknown,
  name: string,
  minLength: number,
  maxLength: number,
): string {
  if (typeof value !== "string") invalid(`${name} must be a string.`);
  const normalized = value.trim();
  if (normalized.length < minLength || normalized.length > maxLength) {
    invalid(`${name} must be ${minLength}-${maxLength} characters.`);
  }
  return normalized;
}

function integer(
  value: unknown,
  name: string,
  minimum: number,
  maximum: number,
): number {
  if (
    typeof value !== "number" ||
    !Number.isSafeInteger(value) ||
    value < minimum ||
    value > maximum
  ) {
    invalid(`${name} must be an integer between ${minimum} and ${maximum}.`);
  }
  return value;
}

function finiteNumber(
  value: unknown,
  name: string,
  minimum: number,
  maximum: number,
): number {
  if (
    typeof value !== "number" ||
    !Number.isFinite(value) ||
    value < minimum ||
    value > maximum
  ) {
    invalid(`${name} must be a number between ${minimum} and ${maximum}.`);
  }
  return value;
}

function optionalTimestamp(value: unknown, name: string): number | null {
  if (value === undefined || value === null) return null;
  return integer(value, name, 0, Number.MAX_SAFE_INTEGER);
}

function identifier(value: unknown, name: string): string {
  const result = string(value, name, 1, 128);
  if (!/^[A-Za-z0-9_-]+$/.test(result)) {
    invalid(`${name} contains unsupported characters.`);
  }
  return result;
}

function optionalIdentifier(value: unknown, name: string): string | null {
  if (value === undefined || value === null) return null;
  return identifier(value, name);
}

function cancelReason(value: unknown): CancelReason {
  switch (value) {
    case "paused":
    case "finished":
    case "stopped":
    case "featureDisabled":
    case "premiumRevoked":
    case "disposed":
    case "staleSession":
      return value;
    default:
      invalid("reason is not a supported cancellation reason.");
  }
}

function fingerprint(value: unknown): string {
  const result = string(value, "fingerprint", 16, 128);
  if (!/^[A-Za-z0-9_-]+$/.test(result)) {
    invalid("fingerprint must be hexadecimal or base64url text.");
  }
  return result;
}

function environment(
  value: unknown,
  expectedEnvironment: ApnsEnvironment,
): ApnsEnvironment {
  if (value !== "sandbox" && value !== "production") {
    invalid("environment must be sandbox or production.");
  }
  if (value !== expectedEnvironment) {
    invalid("environment does not match this backend deployment.");
  }
  return value;
}

function pushToken(value: unknown): string {
  const result = string(value, "token", 32, 512).toLowerCase();
  if (result.length % 2 !== 0 || !/^[0-9a-f]+$/.test(result)) {
    invalid("token must be an even-length hexadecimal ActivityKit push token.");
  }
  return result;
}

function contentState(value: unknown, eventIndex: number): LiveActivityContentState {
  const state = object(value, `events[${eventIndex}].contentState`);
  const prefix = `events[${eventIndex}].contentState`;
  return {
    status: string(state.status, `${prefix}.status`, 1, 32),
    statusText: string(state.statusText, `${prefix}.statusText`, 0, 160),
    intervalText: string(state.intervalText, `${prefix}.intervalText`, 0, 120),
    primaryMetric: string(
      state.primaryMetric,
      `${prefix}.primaryMetric`,
      0,
      120,
    ),
    secondaryMetric: string(
      state.secondaryMetric,
      `${prefix}.secondaryMetric`,
      0,
      120,
    ),
    durationText: string(state.durationText, `${prefix}.durationText`, 0, 120),
    timerStartAtMs: integer(
      state.timerStartAtMs,
      `${prefix}.timerStartAtMs`,
      0,
      Number.MAX_SAFE_INTEGER,
    ),
    timerEndAtMs: integer(
      state.timerEndAtMs,
      `${prefix}.timerEndAtMs`,
      0,
      Number.MAX_SAFE_INTEGER,
    ),
    workoutEndAtMs: integer(
      state.workoutEndAtMs,
      `${prefix}.workoutEndAtMs`,
      0,
      Number.MAX_SAFE_INTEGER,
    ),
    pausedRemainingSeconds: integer(
      state.pausedRemainingSeconds,
      `${prefix}.pausedRemainingSeconds`,
      0,
      8 * 60 * 60,
    ),
    progress: finiteNumber(state.progress, `${prefix}.progress`, 0, 1),
  };
}

function action(value: unknown, index: number): ScheduleAction {
  if (value !== "update" && value !== "end") {
    invalid(`events[${index}].action must be update or end.`);
  }
  return value;
}

function normalizeEvents(
  value: unknown,
  generatedAtMs: number,
  expiresAtMs: number,
  nowMs: number,
): ScheduleEvent[] {
  if (!Array.isArray(value)) invalid("events must be an array.");
  if (value.length < 1 || value.length > MAX_SCHEDULE_EVENTS) {
    invalid(`events must contain 1-${MAX_SCHEDULE_EVENTS} items.`);
  }

  const events: ScheduleEvent[] = [];
  let previousSequence = -1;
  let previousDelivery = -1;
  let endCount = 0;

  value.forEach((rawEvent, index) => {
    const input = object(rawEvent, `events[${index}]`);
    const sequence = integer(
      input.sequence,
      `events[${index}].sequence`,
      0,
      Number.MAX_SAFE_INTEGER,
    );
    const deliverAtMs = integer(
      input.deliverAtMs,
      `events[${index}].deliverAtMs`,
      0,
      Number.MAX_SAFE_INTEGER,
    );
    const normalizedAction = action(input.action, index);
    const staleAtMs = optionalTimestamp(
      input.staleAtMs,
      `events[${index}].staleAtMs`,
    );
    const dismissalAtMs = optionalTimestamp(
      input.dismissalAtMs,
      `events[${index}].dismissalAtMs`,
    );
    const normalized: ScheduleEvent = {
      sequence,
      deliverAtMs,
      action: normalizedAction,
      contentState: contentState(input.contentState, index),
      staleAtMs,
      dismissalAtMs,
    };

    if (sequence <= previousSequence) {
      invalid("event sequences must be strictly increasing.");
    }
    if (deliverAtMs <= previousDelivery) {
      invalid("event delivery times must be strictly increasing.");
    }
    if (deliverAtMs < generatedAtMs - MAX_CLOCK_SKEW_MS) {
      invalid("events cannot be scheduled before generatedAtMs.");
    }
    if (deliverAtMs > generatedAtMs + MAX_ACTIVITY_HORIZON_MS) {
      invalid("events cannot exceed the eight-hour Live Activity horizon.");
    }
    if (deliverAtMs > expiresAtMs) {
      invalid("event delivery cannot be after expiresAtMs.");
    }
    if (staleAtMs !== null && staleAtMs < deliverAtMs) {
      invalid("staleAtMs cannot be before deliverAtMs.");
    }
    if (normalizedAction === "update" && dismissalAtMs !== null) {
      invalid("dismissalAtMs is only valid for the end event.");
    }
    if (normalizedAction === "end") {
      endCount += 1;
      if (index !== value.length - 1) {
        invalid("the end event must be the final event.");
      }
      if (
        dismissalAtMs !== null &&
        (dismissalAtMs < deliverAtMs ||
          dismissalAtMs > deliverAtMs + 4 * 60 * 60 * 1_000)
      ) {
        invalid("dismissalAtMs must be within four hours of the end event.");
      }
    }
    if (activityKitPayloadBytes(normalized, nowMs) > MAX_APNS_PAYLOAD_BYTES) {
      invalid(`events[${index}] exceeds the 4 KB ActivityKit payload limit.`);
    }

    events.push(normalized);
    previousSequence = sequence;
    previousDelivery = deliverAtMs;
  });

  if (endCount !== 1) invalid("events must contain exactly one final end event.");
  return events;
}

function digestEvents(events: ScheduleEvent[]): string {
  return createHash("sha256")
    .update(JSON.stringify(events), "utf8")
    .digest("hex");
}

export function validateUpsertSchedule(
  value: unknown,
  nowMs: number,
  expectedEnvironment: ApnsEnvironment,
): UpsertScheduleCommand {
  const input = object(value, "data");
  const schemaVersion = integer(input.schemaVersion, "schemaVersion", 1, 1);
  if (schemaVersion !== LIVE_ACTIVITY_SCHEMA_VERSION) {
    invalid("unsupported schemaVersion.");
  }
  const generatedAtMs = integer(
    input.generatedAtMs,
    "generatedAtMs",
    0,
    Number.MAX_SAFE_INTEGER,
  );
  if (
    generatedAtMs < nowMs - MAX_ACTIVITY_HORIZON_MS ||
    generatedAtMs > nowMs + MAX_CLOCK_SKEW_MS
  ) {
    invalid("generatedAtMs must be within the eight-hour activity horizon.");
  }
  const expiresAtMs = integer(
    input.expiresAtMs,
    "expiresAtMs",
    0,
    Number.MAX_SAFE_INTEGER,
  );
  if (
    expiresAtMs <= nowMs ||
    expiresAtMs > nowMs + MAX_SESSION_LIFETIME_MS ||
    expiresAtMs > generatedAtMs + MAX_SESSION_LIFETIME_MS
  ) {
    invalid("expiresAtMs must be in the next 12 hours.");
  }
  const events = normalizeEvents(
    input.events,
    generatedAtMs,
    expiresAtMs,
    nowMs,
  );
  return {
    schemaVersion,
    sessionId: identifier(input.sessionId, "sessionId"),
    activityId: identifier(input.activityId, "activityId"),
    token: pushToken(input.token),
    environment: environment(input.environment, expectedEnvironment),
    tokenVersion: integer(
      input.tokenVersion,
      "tokenVersion",
      0,
      Number.MAX_SAFE_INTEGER,
    ),
    scheduleRevision: integer(
      input.scheduleRevision,
      "scheduleRevision",
      1,
      Number.MAX_SAFE_INTEGER,
    ),
    fingerprint: fingerprint(input.fingerprint),
    generatedAtMs,
    expiresAtMs,
    events,
    eventDigest: digestEvents(events),
  };
}

export function validateCancelSchedule(
  value: unknown,
  nowMs: number,
): CancelScheduleCommand {
  const input = object(value, "data");
  const schemaVersion = integer(input.schemaVersion, "schemaVersion", 1, 1);
  const canceledAtMs = integer(
    input.canceledAtMs,
    "canceledAtMs",
    0,
    Number.MAX_SAFE_INTEGER,
  );
  if (
    canceledAtMs < nowMs - 15 * 60 * 1_000 ||
    canceledAtMs > nowMs + MAX_CLOCK_SKEW_MS
  ) {
    invalid("canceledAtMs is outside the accepted clock-skew window.");
  }
  return {
    schemaVersion,
    sessionId: identifier(input.sessionId, "sessionId"),
    activityId: optionalIdentifier(input.activityId, "activityId"),
    scheduleRevision: integer(
      input.scheduleRevision,
      "scheduleRevision",
      1,
      Number.MAX_SAFE_INTEGER,
    ),
    reason: cancelReason(input.reason),
    canceledAtMs,
  };
}

export function validateDispatchTask(value: unknown): DispatchTaskPayload {
  const input = object(value, "task.data");
  return {
    schemaVersion: integer(input.schemaVersion, "schemaVersion", 1, 1),
    sessionId: identifier(input.sessionId, "sessionId"),
    scheduleRevision: integer(
      input.scheduleRevision,
      "scheduleRevision",
      1,
      Number.MAX_SAFE_INTEGER,
    ),
    eventIndex: integer(
      input.eventIndex,
      "eventIndex",
      0,
      MAX_SCHEDULE_EVENTS - 1,
    ),
    sequence: integer(
      input.sequence,
      "sequence",
      0,
      Number.MAX_SAFE_INTEGER,
    ),
    taskId: string(input.taskId, "taskId", 16, 100),
  };
}
