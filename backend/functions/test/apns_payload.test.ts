import { describe, expect, it } from "vitest";

import {
  classifyApnsResponse,
  type ApnsResponseDisposition,
} from "../src/apns/client.js";
import { buildActivityKitPayload } from "../src/apns/payload.js";
import { validateUpsertSchedule } from "../src/domain/validation.js";
import { NOW_MS, rawUpsert } from "./helpers.js";

describe("ActivityKit APNs payload", () => {
  it("contains no alert and uses the supplied monotonic server timestamp", () => {
    const event = validateUpsertSchedule(
      rawUpsert(),
      NOW_MS,
      "sandbox",
    ).events[0];
    expect(event).toBeDefined();
    const payload = buildActivityKitPayload(event!, NOW_MS + 1_999);

    expect(payload.aps.timestamp).toBe(Math.floor(NOW_MS / 1_000) + 1);
    expect(payload.aps.event).toBe("update");
    expect(payload.aps).not.toHaveProperty("alert");
    expect(payload.aps["content-state"].timerEndAtMs).toBeGreaterThan(NOW_MS);
  });

  it.each<[number, string | null, ApnsResponseDisposition]>([
    [200, null, "success"],
    [429, "TooManyRequests", "retry"],
    [500, "InternalServerError", "retry"],
    [410, "Unregistered", "invalid_token"],
    [400, "BadDeviceToken", "invalid_token"],
    [403, "InvalidProviderToken", "permanent_failure"],
  ])("classifies APNs %i/%s as %s", (status, reason, expected) => {
    expect(classifyApnsResponse({ status, reason, apnsId: null })).toBe(expected);
  });
});

