class WalletModel {
  final String id;
  final String bankName; // Tên ngân hàng
  final String accountName; // Tên gợi nhớ (Ví dụ: Ví chính, Thẻ tiết kiệm)
  final double balance;
  final String currency;
  final bool isDefault;

  WalletModel({
    required this.id,
    required this.bankName,
    required this.accountName,
    required this.balance,
    this.currency = 'USD',
    this.isDefault = false,
  });

  factory WalletModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return WalletModel(
      id: id,
      bankName: map['bank_name'] ?? '',
      accountName: map['account_name'] ?? '',
      balance: (map['balance'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      isDefault: map['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bank_name': bankName,
      'account_name': accountName,
      'balance': balance,
      'currency': currency,
      'is_default': isDefault,
    };
  }
}