import {
  defineBoolean,
  defineInt,
  defineJsonSecret,
  defineString,
} from "firebase-functions/params";

import type { ApnsCredentials } from "./apns/client.js";
import type { ApnsEnvironment } from "./domain/types.js";

export const REGION = "asia-northeast3";
export const DISPATCH_FUNCTION_NAME = "dispatchLiveActivityEvent";

export const apnsCredentials = defineJsonSecret<ApnsCredentials>(
  "APNS_CREDENTIALS",
);
export const apnsBundleId = defineString("APNS_BUNDLE_ID", {
  default: "com.nogic.valcue",
  description: "App bundle ID without the .push-type.liveactivity suffix.",
});
export const apnsEnvironment = defineString("APNS_ENVIRONMENT", {
  default: "sandbox",
  description: "APNs endpoint for this Firebase project: sandbox or production.",
});
export const requirePremiumClaim = defineBoolean("REQUIRE_PREMIUM_CLAIM", {
  default: false,
  description:
    "Require a RevenueCat entitlement custom claim. Enable before production.",
});
export const premiumClaimName = defineString("PREMIUM_CLAIM_NAME", {
  default: "revenueCatEntitlements",
});
export const premiumEntitlementId = defineString("PREMIUM_ENTITLEMENT_ID", {
  default: "premium",
});
export const dispatchMinInstances = defineInt("DISPATCH_MIN_INSTANCES", {
  default: 0,
  description: "Set to 1 in production when reduced cold-start latency is worth the cost.",
});

export function deployedApnsEnvironment(): ApnsEnvironment {
  const value = apnsEnvironment.value();
  if (value !== "sandbox" && value !== "production") {
    throw new Error("APNS_ENVIRONMENT must be sandbox or production.");
  }
  return value;
}

