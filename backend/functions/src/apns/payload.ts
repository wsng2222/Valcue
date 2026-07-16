import type { ScheduleEvent } from "../domain/types.js";

export interface ActivityKitPayload {
  aps: {
    timestamp: number;
    event: "update" | "end";
    "content-state": ScheduleEvent["contentState"];
    "stale-date"?: number;
    "dismissal-date"?: number;
  };
}

export function buildActivityKitPayload(
  event: ScheduleEvent,
  nowMs: number,
): ActivityKitPayload {
  const aps: ActivityKitPayload["aps"] = {
    timestamp: Math.floor(nowMs / 1_000),
    event: event.action,
    "content-state": event.contentState,
  };
  if (event.staleAtMs !== null) {
    aps["stale-date"] = Math.floor(event.staleAtMs / 1_000);
  }
  if (event.dismissalAtMs !== null) {
    aps["dismissal-date"] = Math.floor(event.dismissalAtMs / 1_000);
  }
  return { aps };
}

export function activityKitPayloadBytes(
  event: ScheduleEvent,
  nowMs: number,
): number {
  return Buffer.byteLength(
    JSON.stringify(buildActivityKitPayload(event, nowMs)),
    "utf8",
  );
}

