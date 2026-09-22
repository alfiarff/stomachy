import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<void>? _initialization;

  static Future<void> _initialize() {
    return _initialization ??= _googleSignIn.initialize(
      serverClientId:
          '132280576015-t2l30v89jor9cg0ft66f0gu6g0alngi3.apps.googleusercontent.com',
    );
  }

  static Future<UserCredential> signInWithGoogle() async {
    await _initialize();

    final googleUser = await _googleSignIn.authenticate();

    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return FirebaseAuth.instance.signInWithCredential(
      credential,
    );
  }
}