import { type Firestore } from "firebase-admin/firestore";
import { DomainError } from "../domain/errors.js";

const COLLECTION = "sharedRoutines";

export interface SharedRoutine {
  id: string;
  routineData: string;
  createdAtMs: number;
}

export class FirestoreSharedRoutinesRepository {
  readonly #firestore: Firestore;

  constructor(firestore: Firestore) {
    this.#firestore = firestore;
  }

  private generateShortId(): string {
    const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    let result = "";
    for (let i = 0; i < 6; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }

  /**
   * Saves a routine string to Firestore under a unique short ID.
   * Retries on collision up to 5 times.
   */
  async save(routineData: string): Promise<string> {
    const maxRetries = 5;
    for (let attempt = 0; attempt < maxRetries; attempt++) {
      const shortId = this.generateShortId();
      const docRef = this.#firestore.collection(COLLECTION).doc(shortId);

      try {
        const success = await this.#firestore.runTransaction(async (transaction) => {
          const snapshot = await transaction.get(docRef);
          if (snapshot.exists) {
            // Collision, return false to retry in the next loop iteration
            return false;
          }
          const record: SharedRoutine = {
            id: shortId,
            routineData,
            createdAtMs: Date.now(),
          };
          transaction.set(docRef, record);
          return true;
        });

        if (success) {
          return shortId;
        }
      } catch (error) {
        // Log transaction error and retry or throw
        if (attempt === maxRetries - 1) {
          throw new DomainError("internal", "Failed to save shared routine due to database error.");
        }
      }
    }

    throw new DomainError("already-exists", "Failed to generate a unique short ID after multiple attempts.");
  }

  /**
   * Retrieves a shared routine by its short ID.
   */
  async get(id: string): Promise<string | null> {
    try {
      const snapshot = await this.#firestore.collection(COLLECTION).doc(id).get();
      if (!snapshot.exists) {
        return null;
      }
      const data = snapshot.data();
      return (data?.routineData as string) || null;
    } catch (error) {
      throw new DomainError("internal", "Failed to retrieve shared routine from database.");
    }
  }
}
