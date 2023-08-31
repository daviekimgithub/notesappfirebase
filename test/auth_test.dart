import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();
    test("should not be initialides to begin with", () {
      expect(provider.isInitalized, false);
    });
    test("cannot log out", () {
      expect(
        provider.logout(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    test("Should be able to initialize", () {
      expect(provider.initialize(), null);
    });
    test(
      "Should be able to initialize in two seconds",
      () async {
        await provider.initialize();
        expect(provider.initialize(), true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );
    test("Should be able to initialize", () async {
      final badEmailUser = provider.createUser(
        email: "foobar.com",
        password: "anypassword",
      );
      expect(
        badEmailUser,
        throwsA(const TypeMatcher<UserNotFoundException>()),
      );
      provider.createUser(
        email: "someone@bar.com",
        password: "foobar",
      );
      expect(
        badEmailUser,
        throwsA(const TypeMatcher<WrongPasswordException>()),
      );
      final user = await provider.createUser(
        email: "foo",
        password: "bar",
      );
      expect(
        provider.currentUser,
        user,
      );
      expect(user.isEmailVerified, false);
    });
    test("Logged in user should be able to get verified", () async {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test("Should be able to logout and login", () async {
      await provider.logout();
      await provider.login(
        email: "email",
        password: "password",
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _initialized = false;
  bool get isInitalized => _initialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitalized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return login(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _initialized = true;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    if (!isInitalized) throw NotInitializedException();
    if (email == "foobar.com") throw UserNotFoundException();
    if (password == "foobar") throw WrongPasswordException();
    const user =
        AuthUser(isEmailVerified: false, email: 'foobar.com', id: "my_id");
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!isInitalized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitalized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundException();
    const newUser =
        AuthUser(isEmailVerified: true, email: 'foobar.com', id: "my_id");
    _user = newUser;
  }
}
