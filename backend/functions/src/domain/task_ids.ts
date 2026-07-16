import { createHash } from "node:crypto";

import type { DispatchTaskPayload, ScheduleEvent, TaskPlan } from "./types.js";
import { LIVE_ACTIVITY_SCHEMA_VERSION } from "./types.js";

export function sha256Hex(value: string): string {
  return createHash("sha256").update(value, "utf8").digest("hex");
}

export function makeTaskId(
  sessionId: string,
  scheduleRevision: number,
  event: ScheduleEvent,
): string {
  const digest = sha256Hex(
    `${sessionId}\u0000${scheduleRevision}\u0000${event.sequence}`,
  );
  return `la-${digest.slice(0, 48)}`;
}

export function makeTaskPlan(
  sessionId: string,
  scheduleRevision: number,
  eventIndex: number,
  event: ScheduleEvent,
): TaskPlan {
  const taskId = makeTaskId(sessionId, scheduleRevision, event);
  const payload: DispatchTaskPayload = {
    schemaVersion: LIVE_ACTIVITY_SCHEMA_VERSION,
    sessionId,
    scheduleRevision,
    eventIndex,
    sequence: event.sequence,
    taskId,
  };
  return { taskId, deliverAtMs: event.deliverAtMs, payload };
}

export function makeApnsId(
  sessionId: string,
  scheduleRevision: number,
  sequence: number,
): string {
  const hex = sha256Hex(`${sessionId}\u0000${scheduleRevision}\u0000${sequence}`)
    .slice(0, 32)
    .split("");
  // RFC 4122-shaped deterministic request identifier. APNs uses this for
  // tracing; Live Activity timestamp/revision checks provide idempotency.
  hex[12] = "4";
  const variant = Number.parseInt(hex[16] ?? "0", 16);
  hex[16] = ((variant & 0x3) | 0x8).toString(16);
  const compact = hex.join("");
  return `${compact.slice(0, 8)}-${compact.slice(8, 12)}-${compact.slice(12, 16)}-${compact.slice(16, 20)}-${compact.slice(20)}`;
}

