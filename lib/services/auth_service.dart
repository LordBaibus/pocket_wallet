import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase Auth. Every method throws on failure;
/// screens catch and show the message.
class AuthService {
  AuthService._();
  static final instance = AuthService._();

  GoTrueClient get _auth => Supabase.instance.client.auth;

  Stream<AuthState> get authChanges => _auth.onAuthStateChange;
  Session? get session => _auth.currentSession;
  User? get currentUser => _auth.currentUser;

  /// Registration. Returns true if a session was created immediately
  /// (email confirmation disabled), false if the user must confirm by email.
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final res = await _auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    return res.session != null;
  }

  Future<void> signInWithPassword(String email, String password) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  /// Step 1 of OTP login: emails a 6-digit code.
  Future<void> sendOtp(String email) async {
    await _auth.signInWithOtp(email: email, shouldCreateUser: true);
  }

  /// Step 2 of OTP login: verifies the code and signs the user in.
  Future<void> verifyOtp(String email, String code) async {
    await _auth.verifyOTP(email: email, token: code, type: OtpType.email);
  }

  Future<void> resetPassword(String email) async {
    await _auth.resetPasswordForEmail(email);
  }

  /// Native Sign in with Apple -> Supabase session.
  Future<void> signInWithApple() async {
    final rawNonce = _randomNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw AuthException('Apple did not return an identity token.');
    }

    await _auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );

    // Apple only sends the name on the very first authorization.
    final given = credential.givenName;
    if (given != null && given.isNotEmpty) {
      final full = '$given ${credential.familyName ?? ''}'.trim();
      await _auth.updateUser(UserAttributes(data: {'full_name': full}));
    }
  }

  /// Pretty JSON of the current user; also written to the debug console.
  String printCurrentUser() {
    final user = _auth.currentUser;
    final text = user == null
        ? 'No user is signed in.'
        : const JsonEncoder.withIndent('  ').convert(user.toJson());
    debugPrint('CURRENT USER:\n$text');
    return text;
  }

  Future<void> signOut() => _auth.signOut();

  static String _randomNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rnd = Random.secure();
    return List.generate(length, (_) => chars[rnd.nextInt(chars.length)])
        .join();
  }

  /// Human-readable message for any thrown error.
  static String messageOf(Object e) {
    if (e is AuthException) return e.message;
    if (e is SignInWithAppleAuthorizationException &&
        e.code == AuthorizationErrorCode.canceled) {
      return 'Sign in was cancelled.';
    }
    if (e is PostgrestException) return e.message;
    return e.toString();
  }
}
