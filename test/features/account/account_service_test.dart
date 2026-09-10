import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/features/account/account_models.dart';
import 'package:valcue/features/account/account_service.dart';

/// The rules that decide whether someone's records stay attached to them.
void main() {
  group('reading who is signed in', () {
    test('an anonymous user with no provider is a guest', () {
      expect(
        AccountService.kindFor(isAnonymous: true, providerIds: const []),
        AccountKind.guest,
      );
    });

    test('an upgraded guest is no longer reported as a guest', () {
      // Linking keeps the same Firebase user, so only the provider list
      // separates an upgraded account from a guest. Trusting isAnonymous
      // alone would hide the backup option from someone who just signed in.
      expect(
        AccountService.kindFor(
          isAnonymous: false,
          providerIds: const ['google.com'],
        ),
        AccountKind.google,
      );
    });

    test('recognises Apple', () {
      expect(
        AccountService.kindFor(
          isAnonymous: false,
          providerIds: const ['apple.com'],
        ),
        AccountKind.apple,
      );
    });

    test('a signed-in provider wins over a stale anonymous flag', () {
      expect(
        AccountService.kindFor(
          isAnonymous: true,
          providerIds: const ['apple.com'],
        ),
        AccountKind.apple,
      );
    });

    test('an unknown provider is not mistaken for a guest', () {
      expect(
        AccountService.kindFor(
          isAnonymous: false,
          providerIds: const ['facebook.com'],
        ),
        AccountKind.none,
      );
    });
  });

  group('who is allowed to back up', () {
    test('guests are not', () {
      expect(_user(AccountKind.guest).canBackUp, isFalse);
    });

    test('Apple and Google accounts are', () {
      expect(_user(AccountKind.apple).canBackUp, isTrue);
      expect(_user(AccountKind.google).canBackUp, isTrue);
    });
  });

  group('what a sign-in result means for the records on this device', () {
    test('an upgraded guest needs no merge - the id did not change', () {
      const result = SignInResult(SignInStatus.upgradedGuest);

      expect(result.isSuccess, isTrue);
      expect(result.needsMerge, isFalse);
    });

    test('switching to an existing account does need a merge', () {
      // The guest identity is left behind here, so anything on this device
      // has to be folded into the account rather than simply uploaded.
      const result = SignInResult(SignInStatus.switchedToExistingAccount);

      expect(result.isSuccess, isTrue);
      expect(result.needsMerge, isTrue);
    });

    test('cancelling is not a failure', () {
      const result = SignInResult(SignInStatus.cancelled);

      expect(result.isSuccess, isFalse);
      expect(result.needsMerge, isFalse);
    });

    test('a failure is not treated as being signed in', () {
      const result = SignInResult(SignInStatus.failed, errorCode: 'boom');

      expect(result.isSuccess, isFalse);
    });
  });

  group('when Firebase never came up', () {
    // Startup wraps Firebase in a try/catch, so the app can run without it.
    // Every account call has to degrade instead of throwing, or the settings
    // screen becomes unopenable for everyone on that launch.
    test('reports itself unavailable rather than throwing', () {
      final service = _offlineService();

      expect(service.isAvailable, isFalse);
      expect(service.currentUser, isNull);
    });

    test('guest sign-in returns nothing instead of failing loudly', () async {
      expect(await _offlineService().ensureSignedIn(), isNull);
    });

    test('the account stream still emits, so the UI can build', () async {
      expect(await _offlineService().changes.first, isNull);
    });

    test('signing out is a no-op', () async {
      await expectLater(_offlineService().signOut(), completes);
    });

    test('Apple sign-in on a non-Apple platform is refused, not crashed',
        () async {
      final service = _offlineService();

      expect(service.supportsApple, isFalse);
      final result = await service.signInWithApple();
      expect(result.status, SignInStatus.failed);
      expect(result.errorCode, 'apple-unsupported-platform');
    });
  });

  group('Apple nonce', () {
    test('is hashed the way Apple expects', () {
      // Known SHA-256 of "abc", lowercase hex.
      expect(
        AccountService.sha256OfString('abc'),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('hashing is stable for the same input', () {
      expect(
        AccountService.sha256OfString('valcue'),
        AccountService.sha256OfString('valcue'),
      );
    });
  });
}

AccountUser _user(AccountKind kind) => AccountUser(id: 'uid-1', kind: kind);

/// A service on a launch where Firebase failed to initialise. Tests never
/// call Firebase.initializeApp, so FirebaseAuth.instance throws - which is
/// exactly the situation being covered.
AccountService _offlineService() => AccountService(isIOS: () => false);
