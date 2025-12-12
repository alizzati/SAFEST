import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // EMAIL SIGN UP
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // EMAIL LOGIN
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordReset(String email) async {
    if (email.isEmpty) {
      throw Exception("Email cannot be empty.");
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Failed to send password reset email.");
    } catch (e) {
      throw Exception("Unexpected error occurred.");
    }
  }

  // GOOGLE SIGN-IN SIMPLE
  Future<UserCredential> signInWithGoogle() async {
    try {
      // 1. Trigger Sign-In Popup
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: ['email'],
      ).signIn();

      if (googleUser == null) {
        throw Exception("Sign-In was cancelled.");
      }

      // 2. Ambil auth token
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // 3. Convert ke Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Login ke Firebase Auth
      return await FirebaseAuth.instance.signInWithCredential(credential);

    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Google Sign-In failed.");
    } catch (e) {
      throw Exception("Unexpected error occurred: $e");
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
