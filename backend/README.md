# PacePilot background Live Activity backend

운동 화면을 떠나 YouTube·Netflix·음악 앱을 사용하는 동안에도 iOS Live
Activity의 구간 정보를 갱신하는 Firebase 백엔드다. 새 구간의 배너·소리·음성
안내는 앱이 예약한 로컬 알림이 담당하므로 APNs payload에는 `alert`를 넣지
않는다. 이 백엔드는 잠금 화면과 Dynamic Island의 상태만 원격 갱신한다.

## 구성

- Firebase Functions 2nd gen, Node.js 22, `asia-northeast3`
- Firebase callable: `upsertLiveActivitySchedule`,
  `cancelLiveActivitySchedule`
- 비공개 task function: `dispatchLiveActivityEvent`
- Cloud Tasks: 한 세션에서 다음 이벤트 하나만 enqueue
- Firestore: revision CAS, 토큰 회전, 일시정지 상태, 종결 tombstone 저장
- APNs: HTTP/2 + ES256 provider token, sandbox/production 프로젝트 분리

APNs와 Cloud Tasks는 best-effort 전송이다. 네트워크·콜드 스타트·OS 정책 때문에
정확히 같은 밀리초의 갱신을 보장하지 않는다. 작업이 늦으면 이미 지난 여러
구간을 모두 재생하지 않고 가장 최신 이벤트 하나로 합치며, 종료 이벤트가 이미
도래했다면 종료가 우선한다.

## 상태 및 순서 보장

- 요청은 Firebase Auth UID 소유권과 App Check를 모두 검사한다.
- 일정은 최대 56개 이벤트, 생성 시점부터 최대 8시간으로 제한한다. 아직
  `expiresAt`이 지나지 않았다면 이미 지난 boundary가 포함된 일정도 받는다.
  따라서 장시간 운동 중 ActivityKit token만 회전해 같은 revision을 다시
  보내도 거절되지 않으며, task dispatch가 최신 도래 이벤트로 합친다.
- task에는 APNs bearer token을 넣지 않는다. 발송 직전에 최신 Firestore
  revision과 token을 다시 읽는다.
- 동일 revision과 동일 payload는 idempotent다. 낮은 revision은
  `accepted: false`로 무시하며 응답에는 서버의 `acceptedRevision`을 담는다.
- 토큰은 `tokenVersion`이 증가할 때만 교체한다. 원문 토큰은 로그에 남기지
  않는다.
- `paused` 취소는 예약 작업과 원문 토큰을 제거하지만 tombstone을 만들지
  않는다. 더 높은 revision의 upsert로 재개할 수 있다. 등록보다 pause가 먼저
  도착한 placeholder도 이후 activity ID를 최초 바인딩할 수 있다.
- `finished`, `stopped`, `featureDisabled`, `premiumRevoked`, `disposed`,
  `staleSession`은 종결 tombstone이다. 이후 upsert로 부활하지 않는다.
- APNs timestamp는 서버 시각을 사용하고 세션 문서에 기록된 값보다 항상 크게
  만든다.

Firestore 문서에는 TTL용 `expiresAt` Timestamp가 함께 저장된다. Firebase
Console에서 `liveActivitySessions` collection group의 `expiresAt` 필드에 TTL을
활성화해야 종결 문서가 자동 정리된다. 규칙은 모든 client read/write를 거부하며
Admin SDK만 접근한다.

## 최초 설정

Firebase 프로젝트는 개발(sandbox APNs)과 운영(production APNs)을 분리하는
것을 권장한다.

1. Blaze 요금제를 사용하고 Firestore를 `asia-northeast3`에 만든다.
2. Authentication에서 앱이 사용할 로그인 방식을 켠다. 로그인 화면이 없다면
   앱 시작 시 Anonymous Auth로 UID를 확보한다.
3. App Check에 iOS App Attest/DeviceCheck와 Android Play Integrity를 등록한다.
4. Cloud Functions, Cloud Build, Artifact Registry, Cloud Tasks API를 켠다.
5. Apple Developer에서 해당 bundle ID에 Live Activities와 Push
   Notifications capability를 켜고 APNs `.p8` key를 발급한다.
6. Firebase CLI로 프로젝트를 선택하고 secret/parameter를 설정한다.

비밀 값은 저장소에 넣지 않는다. `APNS_CREDENTIALS` JSON 형태는 다음과 같다.

```json
{
  "teamId": "AAAAAAAAAA",
  "keyId": "BBBBBBBBBB",
  "privateKey": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
}
```

예시 명령:

```bash
cd backend
firebase login
firebase use <firebase-project-id>
firebase functions:secrets:set APNS_CREDENTIALS
```

비밀이 아닌 parameter는 `backend/functions/.env.<firebase-project-id>`에 둔다.

```dotenv
APNS_BUNDLE_ID=com.nogic.valcue
APNS_ENVIRONMENT=sandbox
REQUIRE_PREMIUM_CLAIM=false
PREMIUM_CLAIM_NAME=revenueCatEntitlements
PREMIUM_ENTITLEMENT_ID=premium
DISPATCH_MIN_INSTANCES=0
```

운영 프로젝트에서는 `APNS_ENVIRONMENT=production`을 사용한다. 낮은 지연이
비용보다 중요할 때만 `DISPATCH_MIN_INSTANCES=1`을 고려한다.

## 앱 런타임 연결

Firebase Console의 Authentication > Sign-in method에서 **Anonymous** provider를
먼저 활성화한다. 앱은 원격 기능이 실제로 필요할 때 Firebase를 lazy initialize한
후 익명 로그인하며, 이 UID가 세션 소유권 키가 된다.

iOS 앱은 `GoogleService-Info.plist` 대신 build-time `dart-define`으로 이 기능에
필요한 FirebaseOptions를 받는다. Firebase Console > Project settings > 해당 iOS
앱에서 값을 확인해 다음 6개 필수 값을 넘긴다.

```bash
flutter run -d <ios-device> \
  --dart-define=VALCUE_LIVE_ACTIVITY_REMOTE_ENABLED=true \
  --dart-define=VALCUE_FIREBASE_API_KEY=<api-key> \
  --dart-define=VALCUE_FIREBASE_APP_ID=<ios-app-id> \
  --dart-define=VALCUE_FIREBASE_MESSAGING_SENDER_ID=<sender-id> \
  --dart-define=VALCUE_FIREBASE_PROJECT_ID=<firebase-project-id> \
  --dart-define=VALCUE_FIREBASE_IOS_BUNDLE_ID=com.nogic.valcue
```

함수 region을 바꾼 별도 배포에서만 아래 값을 추가한다. 현재 백엔드 기본값과
배포 region은 `asia-northeast3`이다.

```bash
--dart-define=VALCUE_FIREBASE_FUNCTIONS_REGION=asia-northeast3
```

개발 기기/시뮬레이터에서 App Check를 확인할 때만 debug provider를 켠다.

```bash
--dart-define=VALCUE_FIREBASE_APP_CHECK_DEBUG=true
```

앱을 한 번 실행하면 Firebase App Check SDK가 debug token을 Xcode/Flutter 로그에
출력한다. 그 token을 Firebase Console > App Check > Apps > Debug tokens에
등록한 뒤 앱을 다시 실행한다. 등록하지 않으면 두 callable은 의도대로
`failed-precondition`/App Check 오류를 반환한다. 이 define은 Release·TestFlight
빌드에 절대 넣지 않는다. 운영 빌드는 App Attest를 사용하고 지원되지 않는
기기에서는 DeviceCheck로 fallback한다.

필수 define이 없거나 `VALCUE_LIVE_ACTIVITY_REMOTE_ENABLED=false`이면 원격
schedule 전송만 비활성화되고 기존 로컬 알림/ActivityKit 동작은 유지된다.

## 프리미엄 권한

현재 앱의 구매 흐름은 개발용 mock이므로 기본값
`REQUIRE_PREMIUM_CLAIM=false`는 로컬/개발 환경을 띄우기 위한 값일 뿐이다.
이 상태로 운영하면 인증된 모든 사용자가 유료 endpoint를 호출할 수 있다.

운영 전에는 RevenueCat 고객 ID를 Firebase Auth UID와 연결하고, 신뢰할 수 있는
서버 또는 RevenueCat 연동이 Firebase custom claim을 갱신하게 해야 한다. 그런
다음 `REQUIRE_PREMIUM_CLAIM=true`로 배포한다. 클라이언트가 보내는
`isPremium` 값은 절대 권한 근거로 사용하지 않는다. 기본 claim 형식은 아래 두
형태를 지원한다.

```json
{ "revenueCatEntitlements": ["premium"] }
```

```json
{ "revenueCatEntitlements": { "premium": true } }
```

claim 변경 후에는 앱이 Firebase ID token을 강제 refresh해야 새 권한이 반영된다.

## Callable 계약

`upsertLiveActivitySchedule` 입력:

```text
{ schemaVersion, sessionId, activityId, token, environment, tokenVersion,
  scheduleRevision, fingerprint, generatedAtMs, expiresAtMs, events }
```

각 event:

```text
{ sequence, deliverAtMs, action: "update" | "end", contentState,
  staleAtMs?, dismissalAtMs? }
```

`cancelLiveActivitySchedule` 입력:

```text
{ schemaVersion, sessionId, activityId?, scheduleRevision, reason,
  canceledAtMs }
```

두 callable의 응답은 동일하다.

```json
{ "accepted": true, "acceptedRevision": 7 }
```

## 로컬 검증

Node.js 22에서 실행한다.

```bash
cd backend/functions
npm ci
npm run lint
npm test
npm run build
```

Emulator에서 private task까지 실행하려면 실제 운영 키 대신 개발용 sandbox APNs
키를 `backend/functions/.secret.local`에 넣고 App Check debug provider를
사용한다. `.secret.local`, `.env*`, `.firebaserc`는 git에서 제외된다.

## 배포

실제 프로젝트와 APNs 자격 증명을 확인한 뒤 `backend`에서 실행한다.

```bash
firebase deploy --only functions,firestore
```

Functions 배포가 끝난 뒤 위 6개 필수 `dart-define`으로 iOS 빌드를 만들고, 개발
빌드라면 App Check debug token 등록까지 마쳐야 앱과 callable이 연결된다.

배포 후 확인할 항목:

- task queue의 호출 대상이 private인지
- callable에서 App Check 거부 로그가 정상인지
- APNs sandbox/production과 설치 빌드가 일치하는지
- Firestore TTL이 활성화됐는지
- Cloud Tasks/Functions 예산 알림과 오류율 모니터링이 설정됐는지
- 운영 프로젝트에서 premium claim 검사가 켜졌는지

APNs token, `.p8` key, callable 원문 payload는 로그나 분석 도구에 남기지 않는다.
