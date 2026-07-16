import {
  connect as connectHttp2,
  type ClientHttp2Session,
  type IncomingHttpHeaders,
  type OutgoingHttpHeaders,
} from "node:http2";

import { importPKCS8, SignJWT, type CryptoKey } from "jose";

import { RetryableDispatchError } from "../domain/errors.js";
import { makeApnsId, sha256Hex } from "../domain/task_ids.js";
import type {
  ApnsEnvironment,
  ApnsPushRequest,
  ApnsPushResponse,
} from "../domain/types.js";
import { buildActivityKitPayload } from "./payload.js";

const JWT_REFRESH_MS = 50 * 60 * 1_000;
const REQUEST_TIMEOUT_MS = 10_000;
const MAX_RESPONSE_BYTES = 8_192;

export interface ApnsCredentials {
  teamId: string;
  keyId: string;
  privateKey: string;
}

export interface ApnsSender {
  send(request: ApnsPushRequest): Promise<ApnsPushResponse>;
}

export type ApnsResponseDisposition =
  | "success"
  | "retry"
  | "invalid_token"
  | "permanent_failure";

export function classifyApnsResponse(
  response: ApnsPushResponse,
): ApnsResponseDisposition {
  if (response.status === 200) return "success";
  if (response.status === 429 || response.status >= 500) return "retry";
  if (
    response.status === 410 ||
    response.reason === "BadDeviceToken" ||
    response.reason === "DeviceTokenNotForTopic" ||
    response.reason === "Unregistered"
  ) {
    return "invalid_token";
  }
  return "permanent_failure";
}

function origin(environment: ApnsEnvironment): string {
  return environment === "production"
    ? "https://api.push.apple.com"
    : "https://api.sandbox.push.apple.com";
}

function validateCredentials(credentials: ApnsCredentials): ApnsCredentials {
  if (!/^[A-Z0-9]{10}$/.test(credentials.teamId)) {
    throw new Error("APNs teamId must be a 10-character Apple Team ID.");
  }
  if (!/^[A-Z0-9]{10}$/.test(credentials.keyId)) {
    throw new Error("APNs keyId must be a 10-character Apple key ID.");
  }
  if (!credentials.privateKey.includes("BEGIN PRIVATE KEY")) {
    throw new Error("APNs privateKey must contain the .p8 PKCS#8 key.");
  }
  return credentials;
}

class ProviderTokenCache {
  readonly #credentials: ApnsCredentials;
  #key: Promise<CryptoKey> | null = null;
  #token: string | null = null;
  #issuedAtMs = 0;

  constructor(credentials: ApnsCredentials) {
    this.#credentials = validateCredentials(credentials);
  }

  async value(nowMs: number): Promise<string> {
    if (this.#token !== null && nowMs - this.#issuedAtMs < JWT_REFRESH_MS) {
      return this.#token;
    }
    this.#key ??= importPKCS8(this.#credentials.privateKey, "ES256");
    const issuedAt = Math.floor(nowMs / 1_000);
    const token = await new SignJWT({})
      .setProtectedHeader({ alg: "ES256", kid: this.#credentials.keyId })
      .setIssuer(this.#credentials.teamId)
      .setIssuedAt(issuedAt)
      .sign(await this.#key);
    this.#issuedAtMs = nowMs;
    this.#token = token;
    return token;
  }
}

export class ApnsHttp2Sender implements ApnsSender {
  readonly #bundleId: string;
  readonly #providerToken: ProviderTokenCache;
  #session: ClientHttp2Session | null = null;
  #sessionOrigin: string | null = null;

  constructor(bundleId: string, credentials: ApnsCredentials) {
    if (!/^[A-Za-z0-9.-]{3,255}$/.test(bundleId)) {
      throw new Error("Invalid APNs bundle ID.");
    }
    this.#bundleId = bundleId;
    this.#providerToken = new ProviderTokenCache(credentials);
  }

  async send(request: ApnsPushRequest): Promise<ApnsPushResponse> {
    const targetOrigin = origin(request.environment);
    const session = this.#getSession(targetOrigin);
    const authorization = await this.#providerToken.value(request.nowMs);
    const payload = JSON.stringify(
      buildActivityKitPayload(request.event, request.timestampSec * 1_000),
    );
    const apnsId = makeApnsId(
      request.sessionId,
      request.scheduleRevision,
      request.event.sequence,
    );
    const expirationMs = Math.max(
      request.nowMs,
      Math.min(
        request.expiresAtMs,
        request.event.staleAtMs ?? request.expiresAtMs,
      ),
    );
    const headers: OutgoingHttpHeaders = {
      ":method": "POST",
      ":path": `/3/device/${request.token}`,
      authorization: `bearer ${authorization}`,
      "apns-push-type": "liveactivity",
      "apns-topic": `${this.#bundleId}.push-type.liveactivity`,
      "apns-priority": "10",
      "apns-expiration": String(Math.floor(expirationMs / 1_000)),
      "apns-collapse-id": sha256Hex(request.sessionId).slice(0, 48),
      "apns-id": apnsId,
      "content-type": "application/json",
      "content-length": Buffer.byteLength(payload, "utf8"),
    };

    try {
      return await this.#post(session, headers, payload);
    } catch (error) {
      this.#discardSession(session);
      throw new RetryableDispatchError("APNs HTTP/2 request failed.", {
        cause: error,
      });
    }
  }

  #getSession(targetOrigin: string): ClientHttp2Session {
    if (
      this.#session !== null &&
      this.#sessionOrigin === targetOrigin &&
      !this.#session.closed &&
      !this.#session.destroyed
    ) {
      return this.#session;
    }
    if (this.#session !== null) this.#discardSession(this.#session);

    const session = connectHttp2(targetOrigin);
    this.#session = session;
    this.#sessionOrigin = targetOrigin;
    session.once("goaway", () => this.#discardSession(session));
    session.once("close", () => {
      if (this.#session === session) {
        this.#session = null;
        this.#sessionOrigin = null;
      }
    });
    // A session-level error is also emitted on individual request failures.
    // Keep the listener to avoid an unhandled EventEmitter error; the request
    // promise performs the retry classification without logging credentials.
    session.on("error", () => this.#discardSession(session));
    return session;
  }

  #discardSession(session: ClientHttp2Session): void {
    if (this.#session === session) {
      this.#session = null;
      this.#sessionOrigin = null;
    }
    if (!session.destroyed) session.destroy();
  }

  #post(
    session: ClientHttp2Session,
    headers: OutgoingHttpHeaders,
    payload: string,
  ): Promise<ApnsPushResponse> {
    return new Promise((resolve, reject) => {
      const stream = session.request(headers);
      let status = 0;
      let responseApnsId: string | null = null;
      let body = "";
      let settled = false;

      const fail = (error: Error): void => {
        if (settled) return;
        settled = true;
        stream.close();
        reject(error);
      };
      stream.setEncoding("utf8");
      stream.setTimeout(REQUEST_TIMEOUT_MS, () => {
        fail(new Error("APNs request timed out."));
      });
      stream.on("response", (responseHeaders: IncomingHttpHeaders) => {
        const rawStatus = responseHeaders[":status"];
        status = typeof rawStatus === "number" ? rawStatus : Number(rawStatus ?? 0);
        const rawApnsId = responseHeaders["apns-id"];
        responseApnsId = Array.isArray(rawApnsId)
          ? (rawApnsId[0] ?? null)
          : (rawApnsId ?? null);
      });
      stream.on("data", (chunk: string) => {
        if (body.length < MAX_RESPONSE_BYTES) body += chunk;
      });
      stream.once("error", fail);
      stream.once("end", () => {
        if (settled) return;
        settled = true;
        let reason: string | null = null;
        if (body.length > 0) {
          try {
            const decoded = JSON.parse(body) as { reason?: unknown };
            if (typeof decoded.reason === "string") reason = decoded.reason;
          } catch {
            reason = "MalformedApnsResponse";
          }
        }
        resolve({ status, reason, apnsId: responseApnsId });
      });
      stream.end(payload, "utf8");
    });
  }
}
