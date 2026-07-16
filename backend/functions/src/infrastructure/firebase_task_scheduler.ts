import { getFunctions, type TaskQueue } from "firebase-admin/functions";

import type { DispatchTaskPayload, TaskPlan } from "../domain/types.js";
import type { TaskScheduler } from "./task_scheduler.js";

function isAlreadyExists(error: unknown): boolean {
  if (error === null || typeof error !== "object") return false;
  const code = "code" in error ? String(error.code) : "";
  return (
    code === "functions/task-already-exists" ||
    code === "6" ||
    code === "ALREADY_EXISTS"
  );
}

function isNotFound(error: unknown): boolean {
  if (error === null || typeof error !== "object") return false;
  const code = "code" in error ? String(error.code) : "";
  return code === "functions/not-found" || code === "5" || code === "NOT_FOUND";
}

export class FirebaseTaskScheduler implements TaskScheduler {
  readonly #queue: TaskQueue<DispatchTaskPayload>;

  constructor(region: string, functionName: string) {
    this.#queue = getFunctions().taskQueue<DispatchTaskPayload>(
      `locations/${region}/functions/${functionName}`,
    );
  }

  async enqueue(plan: TaskPlan): Promise<void> {
    try {
      await this.#queue.enqueue(plan.payload, {
        id: plan.taskId,
        scheduleTime: new Date(Math.max(Date.now(), plan.deliverAtMs)),
        dispatchDeadlineSeconds: 30,
      });
    } catch (error) {
      // Deterministic task IDs turn retries after an ambiguous network result
      // into a successful idempotent enqueue.
      if (!isAlreadyExists(error)) throw error;
    }
  }

  async delete(taskId: string): Promise<void> {
    try {
      await this.#queue.delete(taskId);
    } catch (error) {
      if (!isNotFound(error)) throw error;
    }
  }
}
