import {
  type DocumentData,
  type Firestore,
  Timestamp,
} from "firebase-admin/firestore";

import type { SessionRecord } from "../domain/types.js";
import type {
  SessionRepository,
  TransactionOutcome,
} from "./session_repository.js";

const COLLECTION = "liveActivitySessions";

function serialize(session: SessionRecord): DocumentData {
  return {
    ...session,
    expiresAt: Timestamp.fromMillis(session.expiresAtMs),
  };
}

function deserialize(data: DocumentData): SessionRecord {
  // Documents are written only by this backend and denied to client SDKs.
  // Runtime request validation protects every externally supplied field.
  return {
    schemaVersion: data.schemaVersion as number,
    sessionId: data.sessionId as string,
    uid: data.uid as string,
    activityId: (data.activityId as string | null) ?? null,
    token: (data.token as string | null) ?? null,
    tokenHash: (data.tokenHash as string | null) ?? null,
    environment: data.environment as SessionRecord["environment"],
    tokenVersion: data.tokenVersion as number,
    scheduleRevision: data.scheduleRevision as number,
    fingerprint: data.fingerprint as string,
    eventDigest: data.eventDigest as string,
    generatedAtMs: data.generatedAtMs as number,
    expiresAtMs: data.expiresAtMs as number,
    events: data.events as SessionRecord["events"],
    nextEventIndex: data.nextEventIndex as number,
    scheduledTaskId: (data.scheduledTaskId as string | null) ?? null,
    enqueuePending: data.enqueuePending as boolean,
    lastDispatchedSequence:
      (data.lastDispatchedSequence as number | null) ?? null,
    lastApnsTimestampSec: (data.lastApnsTimestampSec as number | undefined) ?? 0,
    status: data.status as SessionRecord["status"],
    tombstone: data.tombstone as boolean,
    lastError: (data.lastError as SessionRecord["lastError"]) ?? null,
    createdAtMs: data.createdAtMs as number,
    updatedAtMs: data.updatedAtMs as number,
  };
}

export class FirestoreSessionRepository implements SessionRepository {
  readonly #firestore: Firestore;

  constructor(firestore: Firestore) {
    this.#firestore = firestore;
  }

  async get(sessionId: string): Promise<SessionRecord | null> {
    const snapshot = await this.#firestore.collection(COLLECTION).doc(sessionId).get();
    return snapshot.exists ? deserialize(snapshot.data() ?? {}) : null;
  }

  async transact<T>(
    sessionId: string,
    update: (current: SessionRecord | null) => TransactionOutcome<T>,
  ): Promise<T> {
    const reference = this.#firestore.collection(COLLECTION).doc(sessionId);
    return this.#firestore.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(reference);
      const current = snapshot.exists ? deserialize(snapshot.data() ?? {}) : null;
      const outcome = update(current);
      if (outcome.next !== null) {
        transaction.set(reference, serialize(outcome.next));
      }
      return outcome.value;
    });
  }
}
