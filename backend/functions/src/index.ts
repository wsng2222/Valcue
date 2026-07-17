import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { HttpsError, onCall, type CallableRequest } from "firebase-functions/v2/https";
import { onTaskDispatched } from "firebase-functions/v2/tasks";

import { ApnsHttp2Sender, type ApnsCredentials } from "./apns/client.js";
import {
  apnsBundleId,
  apnsCredentials,
  deployedApnsEnvironment,
  dispatchMinInstances,
  DISPATCH_FUNCTION_NAME,
  premiumClaimName,
  premiumEntitlementId,
  REGION,
  requirePremiumClaim,
} from "./config.js";
import { DomainError } from "./domain/errors.js";
import type { DispatchTaskPayload } from "./domain/types.js";
import {
  validateCancelSchedule,
  validateDispatchTask,
  validateUpsertSchedule,
} from "./domain/validation.js";
import { FirestoreSessionRepository } from "./infrastructure/firestore_session_repository.js";
import { FirebaseTaskScheduler } from "./infrastructure/firebase_task_scheduler.js";
import {
  LiveActivityScheduleService,
  type ServiceLogger,
} from "./service/live_activity_schedule_service.js";
import { FirestoreSharedRoutinesRepository } from "./infrastructure/shared_routines_repository.js";

if (getApps().length === 0) initializeApp();

const repository = new FirestoreSessionRepository(getFirestore());
const sharedRoutinesRepository = new FirestoreSharedRoutinesRepository(getFirestore());
const scheduler = new FirebaseTaskScheduler(REGION, DISPATCH_FUNCTION_NAME);
const serviceLogger: ServiceLogger = {
  info: (message, data) => logger.info(message, data),
  warn: (message, data) => logger.warn(message, data),
  error: (message, data) => logger.error(message, data),
};

let sender: ApnsHttp2Sender | null = null;

function callableService(): LiveActivityScheduleService {
  return new LiveActivityScheduleService({
    repository,
    scheduler,
    environment: deployedApnsEnvironment(),
    logger: serviceLogger,
  });
}

function dispatchService(): LiveActivityScheduleService {
  if (sender === null) {
    const raw = apnsCredentials.value();
    const credentials: ApnsCredentials = {
      teamId: raw.teamId,
      keyId: raw.keyId,
      privateKey: raw.privateKey.replaceAll("\\n", "\n"),
    };
    sender = new ApnsHttp2Sender(apnsBundleId.value(), credentials);
  }
  return new LiveActivityScheduleService({
    repository,
    scheduler,
    sender,
    environment: deployedApnsEnvironment(),
    logger: serviceLogger,
  });
}

function callerUid(request: CallableRequest<unknown>): string {
  if (request.auth === undefined) {
    throw new HttpsError("unauthenticated", "Firebase Authentication is required.");
  }
  if (request.app === undefined) {
    throw new HttpsError("failed-precondition", "Firebase App Check is required.");
  }
  if (requirePremiumClaim.value()) {
    const claim = request.auth.token[premiumClaimName.value()];
    const entitlement = premiumEntitlementId.value();
    const entitled =
      (Array.isArray(claim) && claim.includes(entitlement)) ||
      (claim !== null &&
        typeof claim === "object" &&
        entitlement in claim &&
        Boolean((claim as Record<string, unknown>)[entitlement]));
    if (!entitled) {
      throw new HttpsError(
        "permission-denied",
        "An active premium entitlement is required.",
      );
    }
  }
  return request.auth.uid;
}

function asHttpsError(error: unknown): HttpsError {
  if (error instanceof HttpsError) return error;
  if (error instanceof DomainError) {
    return new HttpsError(error.code, error.message);
  }
  logger.error("Unhandled Live Activity callable error.", {
    error: error instanceof Error ? error.name : "UnknownError",
  });
  return new HttpsError("internal", "Unable to update the Live Activity schedule.");
}

const callableOptions = {
  region: REGION,
  enforceAppCheck: true,
  timeoutSeconds: 30,
  memory: "256MiB" as const,
  maxInstances: 20,
};

export const upsertLiveActivitySchedule = onCall(
  callableOptions,
  async (request) => {
    try {
      const uid = callerUid(request);
      const command = validateUpsertSchedule(
        request.data,
        Date.now(),
        deployedApnsEnvironment(),
      );
      const result = await callableService().upsert(uid, command);
      return {
        accepted: result.accepted,
        acceptedRevision: result.acceptedRevision,
      };
    } catch (error) {
      throw asHttpsError(error);
    }
  },
);

export const cancelLiveActivitySchedule = onCall(
  callableOptions,
  async (request) => {
    try {
      const uid = callerUid(request);
      const command = validateCancelSchedule(request.data, Date.now());
      const result = await callableService().cancel(uid, command);
      return {
        accepted: result.accepted,
        acceptedRevision: result.acceptedRevision,
      };
    } catch (error) {
      throw asHttpsError(error);
    }
  },
);

export const dispatchLiveActivityEvent = onTaskDispatched<DispatchTaskPayload>(
  {
    region: REGION,
    invoker: "private",
    secrets: [apnsCredentials],
    minInstances: dispatchMinInstances,
    timeoutSeconds: 30,
    memory: "256MiB",
    concurrency: 20,
    maxInstances: 20,
    retryConfig: {
      maxAttempts: 6,
      maxRetrySeconds: 5 * 60,
      minBackoffSeconds: 2,
      maxBackoffSeconds: 30,
      maxDoublings: 4,
    },
    rateLimits: {
      maxConcurrentDispatches: 50,
      maxDispatchesPerSecond: 100,
    },
  },
  async (request) => {
    let payload: DispatchTaskPayload;
    try {
      payload = validateDispatchTask(request.data);
    } catch (error) {
      logger.error("Discarding malformed private Live Activity task.", {
        error: error instanceof Error ? error.message : "UnknownError",
      });
      return;
    }
    if (request.id !== payload.taskId) {
      logger.error("Discarding Live Activity task with mismatched identity.", {
        taskId: request.id,
      });
      return;
    }
    await dispatchService().dispatch(payload);
  },
);

function validateAuthenticatedCaller(request: CallableRequest<unknown>): string {
  if (request.auth === undefined) {
    throw new HttpsError("unauthenticated", "Firebase Authentication is required.");
  }
  if (request.app === undefined) {
    throw new HttpsError("failed-precondition", "Firebase App Check is required.");
  }
  return request.auth.uid;
}

export const shareRoutine = onCall(
  callableOptions,
  async (request) => {
    try {
      validateAuthenticatedCaller(request);
      const { routineData } = request.data as { routineData?: string };
      if (!routineData || typeof routineData !== "string") {
        throw new HttpsError("invalid-argument", "The 'routineData' field is required and must be a string.");
      }
      const id = await sharedRoutinesRepository.save(routineData);
      return { id };
    } catch (error) {
      throw asHttpsError(error);
    }
  }
);

export const getSharedRoutine = onCall(
  callableOptions,
  async (request) => {
    try {
      validateAuthenticatedCaller(request);
      const { id } = request.data as { id?: string };
      if (!id || typeof id !== "string") {
        throw new HttpsError("invalid-argument", "The 'id' field is required and must be a string.");
      }
      const routineData = await sharedRoutinesRepository.get(id);
      if (routineData === null) {
        throw new HttpsError("not-found", "Shared routine not found.");
      }
      return { routineData };
    } catch (error) {
      throw asHttpsError(error);
    }
  }
);


