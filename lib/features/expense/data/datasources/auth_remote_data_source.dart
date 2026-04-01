import 'package:expense_manager_app/core/services/rtdb_service.dart';
import 'package:expense_manager_app/features/expense/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sửa tên biến từ _firestoreService thành _rtdbService cho đúng bản chất
  final RTDBService _rtdbService = RTDBService();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Gọi hàm helper để lưu user
      if (userCredential.user != null) {
        await _saveUserToRTDB(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signUpEmailPwd(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lưu thông tin user vào RTDB ngay khi đăng ký thành công
      if (userCredential.user != null) {
        await _saveUserToRTDB(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signInEmailPwd(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Thường thì login không cần lưu lại, nhưng nếu bạn muốn cập nhật
      // thời gian login hoặc đảm bảo user luôn có trong DB thì gọi ở đây:
      if (userCredential.user != null) {
        await _saveUserToRTDB(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Hàm Helper dùng chung để tránh lặp code (DRY - Don't Repeat Yourself)
  Future<void> _saveUserToRTDB(User user) async {
    final newUser = UserModel(
      uid: user.uid,
      email: user.email ?? "",
      photoUrl: user.photoURL ?? "",
      createdAt: DateTime.now().toIso8601String(),
      // Dùng ISO8601 cho chuẩn format
      currency: 'USD',
    );

    // Đảm bảo trong RTDBService bạn đã đổi tên hàm thành saveUser hoặc tương ứng
    await _rtdbService.saveUser(newUser);
  }
}
