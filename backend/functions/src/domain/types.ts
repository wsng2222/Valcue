export const LIVE_ACTIVITY_SCHEMA_VERSION = 1;
export const MAX_SCHEDULE_EVENTS = 56;

export type ApnsEnvironment = "sandbox" | "production";
export type ScheduleAction = "update" | "end";
export type SessionStatus =
  | "active"
  | "paused"
  | "cancelled"
  | "ended"
  | "invalid_token"
  | "failed";
export type CancelReason =
  | "paused"
  | "finished"
  | "stopped"
  | "featureDisabled"
  | "premiumRevoked"
  | "disposed"
  | "staleSession";

export interface LiveActivityContentState {
  status: string;
  statusText: string;
  intervalText: string;
  primaryMetric: string;
  secondaryMetric: string;
  durationText: string;
  timerStartAtMs: number;
  timerEndAtMs: number;
  workoutEndAtMs: number;
  pausedRemainingSeconds: number;
  progress: number;
}

export interface ScheduleEvent {
  sequence: number;
  deliverAtMs: number;
  action: ScheduleAction;
  contentState: LiveActivityContentState;
  staleAtMs: number | null;
  dismissalAtMs: number | null;
}

export interface UpsertScheduleCommand {
  schemaVersion: number;
  sessionId: string;
  activityId: string;
  token: string;
  environment: ApnsEnvironment;
  tokenVersion: number;
  scheduleRevision: number;
  fingerprint: string;
  generatedAtMs: number;
  expiresAtMs: number;
  events: ScheduleEvent[];
  eventDigest: string;
}

export interface CancelScheduleCommand {
  schemaVersion: number;
  sessionId: string;
  activityId: string | null;
  scheduleRevision: number;
  reason: CancelReason;
  canceledAtMs: number;
}

export interface ScheduleMutationResult {
  accepted: boolean;
  acceptedRevision: number;
  status: SessionStatus;
}

export interface SessionErrorRecord {
  code: string;
  reason: string;
  atMs: number;
}

export interface SessionRecord {
  schemaVersion: number;
  sessionId: string;
  uid: string;
  activityId: string | null;
  token: string | null;
  tokenHash: string | null;
  environment: ApnsEnvironment;
  tokenVersion: number;
  scheduleRevision: number;
  fingerprint: string;
  eventDigest: string;
  generatedAtMs: number;
  expiresAtMs: number;
  events: ScheduleEvent[];
  nextEventIndex: number;
  scheduledTaskId: string | null;
  enqueuePending: boolean;
  lastDispatchedSequence: number | null;
  lastApnsTimestampSec: number;
  status: SessionStatus;
  tombstone: boolean;
  lastError: SessionErrorRecord | null;
  createdAtMs: number;
  updatedAtMs: number;
}

export interface DispatchTaskPayload {
  schemaVersion: number;
  sessionId: string;
  scheduleRevision: number;
  eventIndex: number;
  sequence: number;
  taskId: string;
}

export interface TaskPlan {
  taskId: string;
  deliverAtMs: number;
  payload: DispatchTaskPayload;
}

export interface ApnsPushRequest {
  environment: ApnsEnvironment;
  token: string;
  sessionId: string;
  activityId: string;
  scheduleRevision: number;
  expiresAtMs: number;
  event: ScheduleEvent;
  nowMs: number;
  timestampSec: number;
}

export interface ApnsPushResponse {
  status: number;
  reason: string | null;
  apnsId: string | null;
}
