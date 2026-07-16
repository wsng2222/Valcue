import type { SessionRecord } from "../domain/types.js";

export interface TransactionOutcome<T> {
  value: T;
  next: SessionRecord | null;
}

export interface SessionRepository {
  get(sessionId: string): Promise<SessionRecord | null>;

  transact<T>(
    sessionId: string,
    update: (current: SessionRecord | null) => TransactionOutcome<T>,
  ): Promise<T>;
}

