// lib/core/utils/fake_data_seeder.dart

import 'dart:math';
import 'package:firebase_database/firebase_database.dart';

class FakeDataSeeder {
  static final _db = FirebaseDatabase.instance.ref();
  static final _random = Random();

  // Gọi hàm này 1 lần để seed dữ liệu test
  static Future<void> seed(String uid, {int count = 50}) async {
    final Map<String, dynamic> updates = {};
    final now = DateTime.now();

    for (int i = 0; i < count; i++) {
      // Ngày ngẫu nhiên trong vòng 60 ngày gần đây
      final daysAgo = _random.nextInt(60);
      final date = now.subtract(Duration(days: daysAgo));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Loại giao dịch ngẫu nhiên
      final type = _randomType();
      final isExpense = type == 'expense';

      // Số tiền ngẫu nhiên
      final amount = _randomAmount(isExpense);

      // Category ngẫu nhiên theo loại
      final category = isExpense
          ? _randomExpenseCategory()
          : _randomIncomeCategory();

      final String? txKey = _db.child('transactions/$uid').push().key;
      if (txKey == null) continue;

      updates['transactions/$uid/$txKey'] = {
        'type': type,
        'amount': amount,
        'name': _randomName(type, category),
        'category': category,
        'walletId': 'test_wallet',
        'toWalletId': null,
        'date': dateStr,
        'createdAt': date
            .subtract(Duration(
          hours: _random.nextInt(12),
          minutes: _random.nextInt(60),
        ))
            .millisecondsSinceEpoch,
      };
    }

    await _db.update(updates);
    print('✅ Đã seed $count giao dịch test cho uid: $uid');
  }

  // Xóa toàn bộ dữ liệu test
  static Future<void> clear(String uid) async {
    await _db.child('transactions/$uid').remove();
    print('🗑️ Đã xóa toàn bộ giao dịch test');
  }

  // --- Helpers ---

  static String _randomType() {
    final r = _random.nextInt(10);
    if (r < 6) return 'expense';  // 60% chi
    if (r < 9) return 'income';   // 30% thu
    return 'transfer';             // 10% chuyển
  }

  static double _randomAmount(bool isExpense) {
    if (isExpense) {
      // Chi: 10K → 2M
      final amounts = [10000, 20000, 35000, 50000, 75000, 100000,
        150000, 200000, 350000, 500000, 750000, 1000000, 2000000];
      return amounts[_random.nextInt(amounts.length)].toDouble();
    } else {
      // Thu: 500K → 20M
      final amounts = [500000, 1000000, 2000000, 3000000,
        5000000, 7000000, 10000000, 15000000, 20000000];
      return amounts[_random.nextInt(amounts.length)].toDouble();
    }
  }

  static String _randomExpenseCategory() {
    const categories = [
      'Ăn uống', 'Di chuyển', 'Mua sắm', 'Giải trí',
      'Sức khỏe', 'Giáo dục', 'Hóa đơn', 'Khác',
    ];
    return categories[_random.nextInt(categories.length)];
  }

  static String _randomIncomeCategory() {
    const categories = ['Lương', 'Thưởng', 'Đầu tư', 'Khác'];
    return categories[_random.nextInt(categories.length)];
  }

  static String _randomName(String type, String category) {
    if (type == 'transfer') return 'Chuyển tiền';

    const namesByCategory = {
      'Ăn uống': ['Cơm trưa', 'Cà phê', 'Trà sữa', 'Bún bò', 'Phở', 'Pizza'],
      'Di chuyển': ['Grab', 'Xăng xe', 'Vé xe buýt', 'Taxi', 'Gửi xe'],
      'Mua sắm': ['Shopee', 'Lazada', 'Siêu thị', 'Quần áo', 'Giày dép'],
      'Giải trí': ['Netflix', 'Rạp phim', 'Spotify', 'Game', 'Du lịch'],
      'Sức khỏe': ['Khám bệnh', 'Thuốc', 'Gym', 'Vitamin'],
      'Giáo dục': ['Khóa học', 'Sách', 'Học phí'],
      'Hóa đơn': ['Điện', 'Nước', 'Internet', 'Điện thoại'],
      'Lương': ['Lương tháng', 'Lương thưởng'],
      'Thưởng': ['Thưởng KPI', 'Thưởng dự án'],
      'Đầu tư': ['Cổ tức', 'Lãi tiết kiệm'],
      'Khác': ['Thu khác', 'Chi khác'],
    };

    final names = namesByCategory[category] ?? ['Giao dịch'];
    return names[_random.nextInt(names.length)];
  }
}