import 'package:expense_manager_app/core/services/rtdb_service.dart';
import 'package:expense_manager_app/features/expense/data/models/wallet_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransferState {
  final WalletModel? fromWallet;
  final WalletModel? toWallet;
  final bool isSaving;

  const TransferState({
    this.fromWallet,
    this.toWallet,
    this.isSaving = false,
  });

  TransferState copyWith({
    WalletModel? fromWallet,
    WalletModel? toWallet,
    bool? isSaving,
  }) {
    return TransferState(
      fromWallet: fromWallet ?? this.fromWallet,
      toWallet: toWallet ?? this.toWallet,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class TransferNotifier extends StateNotifier<TransferState> {
  TransferNotifier() : super(const TransferState());

  // Khởi tạo ví mặc định từ danh sách
  void initWallets(List<WalletModel> wallets) {
    if (wallets.length < 2) return;
    if (state.fromWallet != null) return; // Đã init rồi thì bỏ qua

    final from = wallets.firstWhere(
          (w) => w.isDefault,
      orElse: () => wallets.first,
    );
    final to = wallets.firstWhere(
          (w) => w.id != from.id,
      orElse: () => wallets[1],
    );

    state = state.copyWith(fromWallet: from, toWallet: to);
  }

  void setFrom(WalletModel wallet) =>
      state = state.copyWith(fromWallet: wallet);

  void setTo(WalletModel wallet) =>
      state = state.copyWith(toWallet: wallet);

  void swap() => state = TransferState(
    fromWallet: state.toWallet,
    toWallet: state.fromWallet,
  );

  Future<String?> transfer({
    required String uid,
    required double amount,
    required String note,
  }) async {
    if (state.fromWallet == null || state.toWallet == null) return 'Chưa chọn ví';
    if (state.fromWallet!.id == state.toWallet!.id) return 'Ví nguồn và đích phải khác nhau';
    if (amount <= 0) return 'Số tiền phải lớn hơn 0';
    if (amount > state.fromWallet!.balance) return 'Số dư không đủ';

    state = state.copyWith(isSaving: true);
    try {
      await RTDBService().transferMoney(
        uid: uid,
        fromWalletId: state.fromWallet!.id,
        toWalletId: state.toWallet!.id,
        amount: amount,
        note: note,
      );
      return null; // null = thành công
    } catch (e) {
      return 'Lỗi: ${e.toString()}';
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

final transferProvider =
StateNotifierProvider.autoDispose<TransferNotifier, TransferState>(
      (ref) => TransferNotifier(),
);