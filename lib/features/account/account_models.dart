/// How someone is signed in.
enum AccountKind {
  /// No account yet - the app has not created even a guest identity.
  none,

  /// A guest, kept as an anonymous Firebase user. Nothing is backed up, and
  /// the identity lives only on this device.
  guest,

  /// Signed in with Apple. iOS only.
  apple,

  /// Signed in with Google.
  google,
}

/// A snapshot of who is using the app.
class AccountUser {
  const AccountUser({
    required this.id,
    required this.kind,
    this.email,
    this.displayName,
  });

  /// Firebase UID. Stable across a guest being upgraded to a real account.
  final String id;
  final AccountKind kind;

  /// Apple's private relay addresses land here too, so this is only ever
  /// shown back to the person, never used to identify them.
  final String? email;
  final String? displayName;

  /// Whether this identity can carry a backup. Guests cannot.
  bool get canBackUp => kind == AccountKind.apple || kind == AccountKind.google;
}

/// What happened when someone tried to sign in.
enum SignInStatus {
  /// The guest identity was upgraded in place: same user id, so everything
  /// already on this device keeps belonging to them.
  upgradedGuest,

  /// The credential already belonged to an account, and that account is now
  /// signed in. The guest identity was left behind, so whatever is on this
  /// device still has to be merged into the account's backup.
  switchedToExistingAccount,

  /// A plain sign-in with no guest identity to carry over.
  signedIn,

  /// The person backed out of the provider's sheet. Not an error - never
  /// show a failure message for this.
  cancelled,

  /// Something went wrong. The person stays exactly as they were.
  failed,
}

class SignInResult {
  const SignInResult(this.status, {this.user, this.errorCode});

  final SignInStatus status;
  final AccountUser? user;

  /// Provider or Firebase error code, for logs - never shown as-is.
  final String? errorCode;

  bool get isSuccess =>
      status == SignInStatus.upgradedGuest ||
      status == SignInStatus.switchedToExistingAccount ||
      status == SignInStatus.signedIn;

  /// True when the account already had a life before this device, so local
  /// records need merging rather than simply uploading.
  bool get needsMerge => status == SignInStatus.switchedToExistingAccount;
}
