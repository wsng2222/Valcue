export type DomainErrorCode =
  | "invalid-argument"
  | "not-found"
  | "permission-denied"
  | "failed-precondition"
  | "already-exists"
  | "internal";

export class DomainError extends Error {
  readonly code: DomainErrorCode;

  constructor(code: DomainErrorCode, message: string) {
    super(message);
    this.name = "DomainError";
    this.code = code;
  }
}

export class RetryableDispatchError extends Error {
  constructor(message: string, options?: ErrorOptions) {
    super(message, options);
    this.name = "RetryableDispatchError";
  }
}

