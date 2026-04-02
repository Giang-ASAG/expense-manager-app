import 'package:expense_manager_app/core/services/rtdb_service.dart';
import 'package:expense_manager_app/features/expense/data/models/category_model.dart';
import 'package:expense_manager_app/features/expense/data/models/transaction_model.dart';
import 'package:expense_manager_app/features/expense/data/models/wallet_model.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/transaction_display_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tổng số dư tất cả ví
final totalBalanceProvider = StreamProvider.family.autoDispose<double, String>(
      (ref, uid) => RTDBService().getTotalBalanceStream(uid),
);

// Thu / chi tháng này
final monthlySummaryProvider =
StreamProvider.family.autoDispose<Map<String, double>, String>(
      (ref, uid) => RTDBService().getMonthlySummaryStream(uid),
);

// Dữ liệu chart 7 ngày
final weeklyExpenseProvider =
StreamProvider.family.autoDispose<List<double>, String>(
      (ref, uid) => RTDBService().getWeeklyExpenseStream(uid),
);

// 5 giao dịch gần nhất

// ✅ Đổi TransactionDisplayModel → TransactionModel
final recentTransactionsProvider =
StreamProvider.family.autoDispose<List<TransactionModel>, String>(
      (ref, uid) => RTDBService().getRecentTransactionsStream(uid, limit: 5),
);
final allTransactionsProvider =
StreamProvider.family.autoDispose<List<TransactionModel>, String>(
      (ref, uid) => RTDBService().getTransactionsStream(uid),
);
final expenseImagesProvider =
StreamProvider.family.autoDispose<List<TransactionModel>, String>(
      (ref, uid) => RTDBService().getExpenseImages(uid),
);
// Stream danh sách ví
final walletsProvider =
StreamProvider.family.autoDispose<List<WalletModel>, String>(
      (ref, uid) => RTDBService().getWalletsStream(uid),
);
final categoriesProvider =
StreamProvider.family.autoDispose<List<CategoryModel>, ({String uid, bool isExpense})>(
      (ref, args) => RTDBService().getCategoriesStream(args.uid, args.isExpense),
);