import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../utils/debug_log.dart';
import 'account_models.dart';

/// Signs people in with Apple, Google, or as a guest, and keeps whatever is
/// already on the device attached to them.
///
/// A guest is a real (anonymous) Firebase user, so a guest who later signs in
/// is *upgraded in place* - same user id, nothing orphaned. Only when the
/// chosen credential already belongs to another account does the id change,
/// and callers are told so they can merge instead of assuming an upload.
class AccountService {
  AccountService({
    FirebaseAuth? auth,
    GoogleSignIn? google,
    AppleCredentialProvider? apple,
    bool Function()? isIOS,
  })  : _injectedAuth = auth,
        _google = google ?? GoogleSignIn.instance,
        _apple = apple ?? const _RealAppleCredentialProvider(),
        _isIOS = isIOS ?? (() => Platform.isIOS);

  static final AccountService instance = AccountService();

  final FirebaseAuth? _injectedAuth;
  final GoogleSignIn _google;
  final AppleCredentialProvider _apple;
  final bool Function() _isIOS;

  bool _googleInitialized = false;

  /// Firebase Auth, or null when Firebase never came up.
  ///
  /// Startup wraps Firebase in a try/catch, so a bad network or a broken
  /// config leaves the app running without it. Resolving this lazily keeps
  /// that a missing backup rather than a settings screen that will not open.
  FirebaseAuth? get _authOrNull {
    if (_injectedAuth != null) return _injectedAuth;
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugLog('[AccountService] Firebase Auth unavailable: $e');
      return null;
    }
  }

  /// Whether accounts can be used at all on this launch.
  bool get isAvailable => _authOrNull != null;

  /// Apple sign-in is offered on iOS only. Android users get Google or guest,
  /// which keeps Apple's Service ID and key setup out of the picture.
  bool get supportsApple => _isIOS();

  /// Who is signed in right now, or null if nobody is.
  AccountUser? get currentUser => _toAccountUser(_authOrNull?.currentUser);

  /// Emits on sign-in, sign-out, and token refresh.
  Stream<AccountUser?> get changes {
    final auth = _authOrNull;
    if (auth == null) return Stream<AccountUser?>.value(null);
    return auth.userChanges().map(_toAccountUser);
  }

  /// Creates the guest identity if there isn't one yet. Safe to call twice.
  Future<AccountUser?> ensureSignedIn() async {
    final auth = _authOrNull;
    if (auth == null) return null;
    if (auth.currentUser != null) return currentUser;
    try {
      await auth.signInAnonymously();
      return currentUser;
    } catch (e) {
      debugLog('[AccountService] Guest sign-in failed: $e');
      return null;
    }
  }

  Future<SignInResult> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      if (!_google.supportsAuthenticate()) {
        return const SignInResult(
          SignInStatus.failed,
          errorCode: 'google-authenticate-unsupported',
        );
      }
      final account = await _google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        return const SignInResult(
          SignInStatus.failed,
          errorCode: 'google-missing-id-token',
        );
      }
      return _applyCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const SignInResult(SignInStatus.cancelled);
      }
      debugLog('[AccountService] Google sign-in failed: ${e.code} ${e.description}');
      return SignInResult(SignInStatus.failed, errorCode: e.code.name);
    } catch (e) {
      debugLog('[AccountService] Google sign-in failed: $e');
      return const SignInResult(SignInStatus.failed);
    }
  }

  Future<SignInResult> signInWithApple() async {
    if (!supportsApple) {
      return const SignInResult(
        SignInStatus.failed,
        errorCode: 'apple-unsupported-platform',
      );
    }
    try {
      // Apple signs a nonce we choose, and Firebase checks it against the raw
      // value. Without this, a stolen id token could be replayed.
      final rawNonce = _randomNonce();
      final credential = await _apple.getCredential(
        nonce: sha256OfString(rawNonce),
      );
      final idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        return const SignInResult(
          SignInStatus.failed,
          errorCode: 'apple-missing-id-token',
        );
      }
      return _applyCredential(
        OAuthProvider('apple.com').credential(
          idToken: idToken,
          rawNonce: rawNonce,
        ),
        // Apple hands over a name only on the very first sign-in, so it has
        // to be saved right then or it is gone for good.
        displayName: _appleDisplayName(credential),
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const SignInResult(SignInStatus.cancelled);
      }
      debugLog('[AccountService] Apple sign-in failed: ${e.code} ${e.message}');
      return SignInResult(SignInStatus.failed, errorCode: e.code.name);
    } catch (e) {
      debugLog('[AccountService] Apple sign-in failed: $e');
      return const SignInResult(SignInStatus.failed);
    }
  }

  /// Signs out and drops back to a guest identity, so the app always has
  /// someone to attribute local records to.
  Future<void> signOut() async {
    final auth = _authOrNull;
    if (auth == null) return;
    try {
      await _signOutOfGoogle();
      await auth.signOut();
      await ensureSignedIn();
    } catch (e) {
      debugLog('[AccountService] Sign-out failed: $e');
    }
  }

  /// Links a credential to the current guest where possible, and otherwise
  /// signs in to the account that credential already belongs to.
  Future<SignInResult> _applyCredential(
    AuthCredential credential, {
    String? displayName,
  }) async {
    final auth = _authOrNull;
    if (auth == null) {
      return const SignInResult(
        SignInStatus.failed,
        errorCode: 'firebase-unavailable',
      );
    }
    final guest = auth.currentUser;

    if (guest != null && guest.isAnonymous) {
      try {
        final linked = await guest.linkWithCredential(credential);
        await _saveDisplayName(linked.user, displayName);
        return SignInResult(
          SignInStatus.upgradedGuest,
          user: _toAccountUser(linked.user),
        );
      } on FirebaseAuthException catch (e) {
        // The credential already has an account of its own - typically the
        // same person returning on a new phone. Fall through and sign in to
        // it; the guest's local records are merged by the backup layer.
        const takenCodes = {
          'credential-already-in-use',
          'email-already-in-use',
          'provider-already-linked',
        };
        if (!takenCodes.contains(e.code)) {
          debugLog('[AccountService] Link failed: ${e.code}');
          return SignInResult(SignInStatus.failed, errorCode: e.code);
        }
      }
    }

    try {
      final signedIn = await auth.signInWithCredential(credential);
      await _saveDisplayName(signedIn.user, displayName);
      return SignInResult(
        guest != null && guest.isAnonymous
            ? SignInStatus.switchedToExistingAccount
            : SignInStatus.signedIn,
        user: _toAccountUser(signedIn.user),
      );
    } on FirebaseAuthException catch (e) {
      debugLog('[AccountService] Sign-in failed: ${e.code}');
      return SignInResult(SignInStatus.failed, errorCode: e.code);
    }
  }

  Future<void> _saveDisplayName(User? user, String? displayName) async {
    if (user == null) return;
    final name = displayName?.trim();
    if (name == null || name.isEmpty) return;
    if ((user.displayName ?? '').isNotEmpty) return;
    try {
      await user.updateDisplayName(name);
    } catch (e) {
      debugLog('[AccountService] Could not save display name: $e');
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    // Identifiers come from the bundled config files, so nothing is passed
    // here - see GoogleService-Info.plist and google-services.json.
    await _google.initialize();
    _googleInitialized = true;
  }

  Future<void> _signOutOfGoogle() async {
    if (!_googleInitialized) return;
    try {
      await _google.signOut();
    } catch (e) {
      debugLog('[AccountService] Google sign-out failed: $e');
    }
  }

  static String? _appleDisplayName(AppleIdCredentialData credential) {
    final parts = [credential.givenName, credential.familyName]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);
    final name = parts.join(' ');
    return name.isEmpty ? null : name;
  }

  static AccountUser? _toAccountUser(User? user) {
    if (user == null) return null;
    return AccountUser(
      id: user.uid,
      kind: kindFor(
        isAnonymous: user.isAnonymous,
        providerIds: user.providerData.map((p) => p.providerId).toList(),
      ),
      email: user.email,
      displayName: user.displayName,
    );
  }

  /// Which account kind a Firebase user represents.
  ///
  /// A linked guest keeps `isAnonymous == false` and gains a provider, so the
  /// provider list is what decides - checking `isAnonymous` alone would call
  /// an upgraded account a guest forever.
  static AccountKind kindFor({
    required bool isAnonymous,
    required List<String> providerIds,
  }) {
    if (providerIds.contains('apple.com')) return AccountKind.apple;
    if (providerIds.contains('google.com')) return AccountKind.google;
    if (isAnonymous) return AccountKind.guest;
    return AccountKind.none;
  }

  /// A URL-safe random string, used once per Apple sign-in.
  static String _randomNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Hex SHA-256, the form Apple expects for a nonce.
  static String sha256OfString(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
}

/// The bit of Apple sign-in that needs a real device, split out so the rest
/// can be tested.
abstract class AppleCredentialProvider {
  Future<AppleIdCredentialData> getCredential({required String nonce});
}

/// Just the fields this app uses from an Apple credential.
class AppleIdCredentialData {
  const AppleIdCredentialData({
    this.identityToken,
    this.givenName,
    this.familyName,
    this.email,
  });

  final String? identityToken;
  final String? givenName;
  final String? familyName;
  final String? email;
}

class _RealAppleCredentialProvider implements AppleCredentialProvider {
  const _RealAppleCredentialProvider();

  @override
  Future<AppleIdCredentialData> getCredential({required String nonce}) async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );
    return AppleIdCredentialData(
      identityToken: credential.identityToken,
      givenName: credential.givenName,
      familyName: credential.familyName,
      email: credential.email,
    );
  }
}
