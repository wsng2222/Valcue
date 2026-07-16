import type { ApnsSender } from "../src/apns/client.js";
import type {
  ApnsPushRequest,
  ApnsPushResponse,
  SessionRecord,
  TaskPlan,
} from "../src/domain/types.js";
import type {
  SessionRepository,
  TransactionOutcome,
} from "../src/infrastructure/session_repository.js";
import type { TaskScheduler } from "../src/infrastructure/task_scheduler.js";

export class InMemorySessionRepository implements SessionRepository {
  readonly records = new Map<string, SessionRecord>();

  async get(sessionId: string): Promise<SessionRecord | null> {
    return this.records.get(sessionId) ?? null;
  }

  async transact<T>(
    sessionId: string,
    update: (current: SessionRecord | null) => TransactionOutcome<T>,
  ): Promise<T> {
    const outcome = update(this.records.get(sessionId) ?? null);
    if (outcome.next !== null) this.records.set(sessionId, outcome.next);
    return outcome.value;
  }
}

export class FakeTaskScheduler implements TaskScheduler {
  readonly enqueued: TaskPlan[] = [];
  readonly deleted: string[] = [];
  failNextEnqueue = false;

  async enqueue(plan: TaskPlan): Promise<void> {
    if (this.failNextEnqueue) {
      this.failNextEnqueue = false;
      throw new Error("synthetic enqueue failure");
    }
    if (!this.enqueued.some((candidate) => candidate.taskId === plan.taskId)) {
      this.enqueued.push(plan);
    }
  }

  async delete(taskId: string): Promise<void> {
    this.deleted.push(taskId);
  }
}

export class FakeApnsSender implements ApnsSender {
  readonly requests: ApnsPushRequest[] = [];
  response: ApnsPushResponse = { status: 200, reason: null, apnsId: null };
  beforeResponse: ((request: ApnsPushRequest) => Promise<void>) | null = null;

  async send(request: ApnsPushRequest): Promise<ApnsPushResponse> {
    this.requests.push(request);
    const beforeResponse = this.beforeResponse;
    this.beforeResponse = null;
    if (beforeResponse !== null) await beforeResponse(request);
    return this.response;
  }
}

export const NOW_MS = Date.UTC(2026, 6, 16, 3, 0, 0);

export function contentState(index: number): Record<string, unknown> {
  return {
    status: index === 99 ? "finished" : "running",
    statusText: index === 99 ? "완료" : "운동 중",
    intervalText: `${index + 1}/3 구간`,
    primaryMetric: "속도 8.0 km/h",
    secondaryMetric: "경사도 2%",
    durationText: "1분",
    timerStartAtMs: NOW_MS + index * 60_000,
    timerEndAtMs: index === 99 ? 0 : NOW_MS + (index + 1) * 60_000,
    workoutEndAtMs: index === 99 ? 0 : NOW_MS + 3 * 60_000,
    pausedRemainingSeconds: index === 99 ? 0 : 60,
    progress: index === 99 ? 1 : index / 3,
    // Canonical client payload currently contains additional display metadata.
    // Validation intentionally strips fields the native ContentState ignores.
    routineId: "routine-1",
    intervalIndex: index + 1,
  };
}

export function rawUpsert(options?: {
  revision?: number;
  tokenVersion?: number;
  token?: string;
  fingerprint?: string;
  generatedAtMs?: number;
}): Record<string, unknown> {
  const generatedAtMs = options?.generatedAtMs ?? NOW_MS;
  return {
    schemaVersion: 1,
    sessionId: "123e4567-e89b-42d3-a456-426614174000",
    activityId: "activity-1",
    token: options?.token ?? "ab".repeat(32),
    environment: "sandbox",
    tokenVersion: options?.tokenVersion ?? 1,
    scheduleRevision: options?.revision ?? 1,
    fingerprint: options?.fingerprint ?? "a".repeat(64),
    generatedAtMs,
    expiresAtMs: generatedAtMs + 8 * 60_000,
    events: [
      {
        sequence: 0,
        deliverAtMs: generatedAtMs + 60_000,
        action: "update",
        contentState: contentState(0),
        staleAtMs: generatedAtMs + 2 * 60_000,
      },
      {
        sequence: 1,
        deliverAtMs: generatedAtMs + 2 * 60_000,
        action: "update",
        contentState: contentState(1),
        staleAtMs: generatedAtMs + 3 * 60_000,
      },
      {
        sequence: 2,
        deliverAtMs: generatedAtMs + 3 * 60_000,
        action: "end",
        contentState: contentState(99),
        dismissalAtMs: generatedAtMs + 4 * 60_000,
      },
    ],
  };
}

export function rawLongRunningUpsert(options?: {
  revision?: number;
  tokenVersion?: number;
  token?: string;
  fingerprint?: string;
}): Record<string, unknown> {
  const value = rawUpsert(options);
  const events = value.events as Array<Record<string, unknown>>;
  events[0] = {
    ...events[0],
    deliverAtMs: NOW_MS + 60_000,
    staleAtMs: NOW_MS + 10 * 60_000,
  };
  events[1] = {
    ...events[1],
    deliverAtMs: NOW_MS + 10 * 60_000,
    staleAtMs: NOW_MS + 30 * 60_000,
  };
  events[2] = {
    ...events[2],
    deliverAtMs: NOW_MS + 30 * 60_000,
    dismissalAtMs: NOW_MS + 31 * 60_000,
  };
  value.expiresAtMs = NOW_MS + 35 * 60_000;
  return value;
}

export function rawCancel(options?: {
  revision?: number;
  activityId?: string | null;
  reason?: string;
}): Record<string, unknown> {
  const value: Record<string, unknown> = {
    schemaVersion: 1,
    sessionId: "123e4567-e89b-42d3-a456-426614174000",
    scheduleRevision: options?.revision ?? 2,
    reason: options?.reason ?? "paused",
    canceledAtMs: NOW_MS,
  };
  if (options?.activityId !== null) {
    value.activityId = options?.activityId ?? "activity-1";
  }
  return value;
}
