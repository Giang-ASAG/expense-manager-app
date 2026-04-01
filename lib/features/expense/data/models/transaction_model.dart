// lib/features/expense/data/models/transaction_model.dart

class TransactionModel {
  final String id;
  final String type; // 'expense' | 'income' | 'transfer'
  final double amount;
  final String name;
  final String? category;
  final String walletId;
  final String? toWalletId; // chỉ dùng cho transfer
  final String date;
  final int createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.name,
    this.category,
    required this.walletId,
    this.toWalletId,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': amount,
      'name': name,
      'category': category,
      'walletId': walletId,
      'toWalletId': toWalletId,
      'date': date,
      'createdAt': createdAt,
    };
  }

  factory TransactionModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return TransactionModel(
      id: id,
      type: map['type'] ?? 'expense',
      amount: (map['amount'] ?? 0).toDouble(),
      name: map['name'] ?? '',
      category: map['category'],
      walletId: map['walletId'] ?? '',
      toWalletId: map['toWalletId'],
      date: map['date'] ?? '',
      createdAt: map['createdAt'] ?? 0,
    );
  }
}
