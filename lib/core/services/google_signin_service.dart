import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  // 💡 Version 7.2.0 sử dụng instance tĩnh
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool _initialized = false;

  /// Đảm bảo chỉ initialize một lần duy nhất
  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      print('🔵 Initializing Google Sign-In with serverClientId...');
      // ⚠️ Version 7.2.0 YÊU CẦU gọi initialize trước khi dùng
      await _googleSignIn.initialize(
        // Client ID cho Android (từ google-services.json type 1)
        clientId:
            "811110866452-77j52kt59h9tg137mj449k68cq3j8kkr.apps.googleusercontent.com",
        // Client ID cho Web/Server (từ google-services.json type 3)
        serverClientId:
            "811110866452-kso99eq4ohltu6a2i378n2tfafs6gis5.apps.googleusercontent.com",
      );
      print('✅ Google Sign-In initialized');
    } catch (e) {
      print('❌ GoogleSignIn.initialize Error: $e');
    }
    _initialized = true;
  }

  /// Đăng nhập Google (hiển thị giao diện chọn tài khoản)
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔵 Starting Google Sign-In flow...');
      await _ensureInitialized();

      // 1. Thử đăng nhập im lặng (attemptLightweightAuthentication)
      GoogleSignInAccount? account;
      try {
        print('🔵 Attempting lightweight authentication...');
        final future = _googleSignIn.attemptLightweightAuthentication();
        if (future != null) {
          account = await future;
        }
      } catch (e) {
        print('ℹ️ Lightweight Sign-In failed (expected if no session): $e');
      }

      // 2. Nếu im lặng thất bại, gọi authenticate() để hiện dialog
      if (account == null) {
        print('🔵 Triggering interactive authentication (authenticate)...');
        account = await _googleSignIn.authenticate();
      }

      print('✅ Google Account obtained: ${account.email}');

      // 3. Lấy tokens từ getter authentication
      final auth = account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        print('❌ No ID token received!');
        throw Exception('No ID token received from Google');
      }

      print('🔵 Signing in to Firebase with idToken...');
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      print('✅ Firebase login success: ${userCredential.user?.email}');
      return userCredential;
    } on GoogleSignInException catch (e) {
      // ⚠️ LƯU Ý QUAN TRỌNG:
      // Nếu bạn nhận lỗi "canceled" mà không phải do bạn bấm hủy, 
      // thì 99% là do SHA-1 fingerprint trong Firebase Console chưa khớp với keystore bạn đang dùng.
      if (e.code == GoogleSignInExceptionCode.canceled) {
        print('ℹ️ Google Sign-In canceled (code: ${e.code})');
        print('💡 TIP: Nếu lỗi này hiện ra ngay lập tức, hãy kiểm tra lại SHA-1 trong Firebase Console.');
        return null;
      }
      print('❌ GoogleSignInException: ${e.code} — $e');
      rethrow;
    } catch (e) {
      print('❌ Google Sign-In Error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
    _initialized = false;
  }
}
