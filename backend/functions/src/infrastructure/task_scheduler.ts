import type { TaskPlan } from "../domain/types.js";

export interface TaskScheduler {
  enqueue(plan: TaskPlan): Promise<void>;
  delete(taskId: string): Promise<void>;
}

