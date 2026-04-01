import 'package:expense_manager_app/core/constants/app_constants.dart';
import 'package:expense_manager_app/features/expense/data/models/category_model.dart';
import 'package:expense_manager_app/features/expense/data/models/transaction_model.dart';
import 'package:expense_manager_app/features/expense/data/models/user_model.dart';
import 'package:expense_manager_app/features/expense/data/models/wallet_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class RTDBService {
  // Khởi tạo reference đến node gốc của database
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> saveUser(UserModel user) async {
    try {
      // Lưu vào đường dẫn users/uid_cua_user
      await _dbRef.child('users').child(user.uid).set(user.toJson());
    } catch (e) {
      print("Lỗi lưu RTDB: $e");
      rethrow;
    }
  }

  Future<void> addNewWallet(String uid, WalletModel wallet) async {
    try {
      // push() tạo ra một ID duy nhất cho mỗi ví (giống như số tài khoản)
      final newWalletRef = _dbRef.child('wallets').child(uid).push();
      // Nếu đây là ví đầu tiên, hãy đặt nó làm mặc định (isDefault = true)
      await newWalletRef.set(wallet.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Lấy danh sách tất cả các ví/ngân hàng của User
  Stream<List<WalletModel>> getWalletsStream(String uid) {
    return _dbRef.child('wallets').child(uid).onValue.map((event) {
      final Map<dynamic, dynamic>? walletsMap = event.snapshot.value as Map?;
      if (walletsMap == null) return [];

      return walletsMap.entries.map((e) {
        return WalletModel.fromMap(e.key, Map<dynamic, dynamic>.from(e.value));
      }).toList();
    });
  }
  Stream<double> getTotalBalanceStream(String uid) {
    return getWalletsStream(uid).map((wallets) {
      return wallets.fold(0.0, (sum, wallet) => sum + wallet.balance);
    });
  }
  Stream<List<CategoryModel>> getCategoriesStream(String uid, bool isExpense) {
    return _dbRef.child('categories').child(uid).onValue.map((event) {
      final Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return [];

      return data.entries
          .map((e) {
            return CategoryModel.fromMap(
              e.key.toString(),
              Map<dynamic, dynamic>.from(e.value),
            );
          })
          .where((element) => element.isExpense == isExpense)
          .toList();
    });
  }
  Future<void> addNewCategory(String uid, CategoryModel category) async {
    try {
      // 1. Tạo một node mới với ID ngẫu nhiên trong danh mục của User
      final newCategoryRef = _dbRef.child('categories').child(uid).push();
      // 2. Lưu dữ liệu (Sử dụng toMap đã có isExpense, color, icon...)
      await newCategoryRef.set(category.toMap());
      debugPrint('Thêm danh mục thành công: ${newCategoryRef.key}');
    } catch (e) {
      debugPrint('Lỗi addNewCategory: $e');
      rethrow;
    }
  }

  Future<void> initUserData(String uid) async {
    // Kiểm tra xem user đã có danh mục chưa để tránh ghi đè nếu họ login lại
    final snapshot = await _dbRef.child('categories').child(uid).get();
    if (snapshot.exists) return;

    Map<String, dynamic> updates = {};

    for (var cat in AppConstants.defaultCategories) {
      // Tạo một key ngẫu nhiên cho mỗi danh mục
      final String? newKey = _dbRef.child('categories').child(uid).push().key;
      if (newKey != null) {
        updates['categories/$uid/$newKey'] = cat;
      }
    }

    // Thực hiện ghi hàng loạt vào Firebase
    await _dbRef.update(updates);
  }
  // Future<void> transferMoney({
  //   required String uid,
  //   required String fromWalletId,
  //   required String toWalletId,
  //   required double amount,
  //   String? note,
  // }) async {
  //   final fromRef = _dbRef.child('wallets/$uid/$fromWalletId');
  //   final toRef   = _dbRef.child('wallets/$uid/$toWalletId');
  //
  //   final fromSnap = await fromRef.get();
  //   final toSnap   = await toRef.get();
  //
  //   final fromBalance = (fromSnap.child('balance').value as num).toDouble();
  //   final toBalance   = (toSnap.child('balance').value as num).toDouble();
  //
  //   // Dùng update() để ghi đồng thời, tránh race condition
  //   await _dbRef.update({
  //     'wallets/$uid/$fromWalletId/balance': fromBalance - amount,
  //     'wallets/$uid/$toWalletId/balance':   toBalance   + amount,
  //   });
  // }
  // Lưu giao dịch CHI / THU + cập nhật balance ví
  Future<void> saveTransaction({
    required String uid,
    required String walletId,
    required double amount,
    required String category,
    required String name,
    required bool isExpense,
  }) async {
    final walletRef = _dbRef.child('wallets/$uid/$walletId');
    final walletSnap = await walletRef.get();

    if (!walletSnap.exists) throw Exception('Ví không tồn tại');

    final currentBalance = (walletSnap.child('balance').value as num).toDouble();
    final newBalance = isExpense ? currentBalance - amount : currentBalance + amount;

    final String? txKey = _dbRef.child('transactions/$uid').push().key;

    // Ghi đồng thời transaction + cập nhật balance
    await _dbRef.update({
      'transactions/$uid/$txKey': {
        'type': isExpense ? 'expense' : 'income',
        'amount': amount,
        'name': name,
        'category': category,
        'walletId': walletId,
        'toWalletId': null,
        'date': DateTime.now().toIso8601String().substring(0, 10),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      'wallets/$uid/$walletId/balance': newBalance,
    });
  }
// Cập nhật transferMoney để lưu thêm vào transactions
  Future<void> transferMoney({
    required String uid,
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? note,
  }) async {
    final fromSnap = await _dbRef.child('wallets/$uid/$fromWalletId').get();
    final toSnap   = await _dbRef.child('wallets/$uid/$toWalletId').get();

    if (!fromSnap.exists || !toSnap.exists) throw Exception('Ví không tồn tại');

    final fromBalance = (fromSnap.child('balance').value as num).toDouble();
    final toBalance   = (toSnap.child('balance').value as num).toDouble();

    final String? txKey = _dbRef.child('transactions/$uid').push().key;

    await _dbRef.update({
      // Cập nhật số dư
      'wallets/$uid/$fromWalletId/balance': fromBalance - amount,
      'wallets/$uid/$toWalletId/balance':   toBalance   + amount,
      // Lưu giao dịch
      'transactions/$uid/$txKey': {
        'type': 'transfer',
        'amount': amount,
        'name': note ?? 'Chuyển tiền',
        'category': 'transfer',
        'walletId': fromWalletId,
        'toWalletId': toWalletId,
        'date': DateTime.now().toIso8601String().substring(0, 10),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
    });
  }

// Stream lấy danh sách giao dịch
  Stream<List<TransactionModel>> getTransactionsStream(String uid) {
    return _dbRef
        .child('transactions/$uid')
        .orderByChild('createdAt')
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries
          .map((e) => TransactionModel.fromMap(e.key, e.value))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }
  Future<double> getWalletBalance(String uid, String walletId) async {
    final snap = await _dbRef.child('wallets/$uid/$walletId/balance').get();
    return (snap.value as num?)?.toDouble() ?? 0.0;
  }
// Thêm vào RTDBService
  Stream<List<TransactionModel>> getRecentTransactionsStream(String uid, {int limit = 5}) {
    return _dbRef
        .child('transactions/$uid')
        .orderByChild('createdAt')
        .limitToLast(limit)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries
          .map((e) => TransactionModel.fromMap(e.key, Map<dynamic, dynamic>.from(e.value)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }
}
