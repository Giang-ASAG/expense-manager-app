import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_manager_app/core/services/cloudinary_service.dart';
import 'package:expense_manager_app/core/services/rtdb_service.dart';

// --- State ---
class AddTransactionState {
  final bool isExpense;
  final String selectedCategory;
  final String? selectedWalletId;
  final File? receiptImage;
  final bool isSaving;

  const AddTransactionState({
    this.isExpense = true,
    this.selectedCategory = 'Ăn uống',
    this.selectedWalletId,
    this.receiptImage,
    this.isSaving = false,
  });

  AddTransactionState copyWith({
    bool? isExpense,
    String? selectedCategory,
    String? selectedWalletId,
    File? receiptImage,
    bool? isSaving,
    bool clearImage = false, // dùng để set null
  }) {
    return AddTransactionState(
      isExpense: isExpense ?? this.isExpense,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedWalletId: selectedWalletId ?? this.selectedWalletId,
      receiptImage: clearImage ? null : receiptImage ?? this.receiptImage,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

// --- Notifier ---
class AddTransactionNotifier extends StateNotifier<AddTransactionState> {
  AddTransactionNotifier() : super(const AddTransactionState());

  void setExpenseType(bool isExpense) {
    state = state.copyWith(
      isExpense: isExpense,
      clearImage: !isExpense, // ✅ Xoá ảnh khi chuyển sang Thu nhập
    );
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setWallet(String walletId) {
    state = state.copyWith(selectedWalletId: walletId);
  }

  void setImage(File? file) {
    if (file == null) {
      state = state.copyWith(clearImage: true);
    } else {
      state = state.copyWith(receiptImage: file);
    }
  }

  Future<String?> save({
    required String uid,
    required String name,
    required double amount,
  }) async {
    if (state.selectedWalletId == null) return 'Vui lòng chọn ví';

    // Kiểm tra số dư
    if (state.isExpense) {
      final currentBalance = await RTDBService().getWalletBalance(
        uid,
        state.selectedWalletId!,
      );
      if (amount > currentBalance) {
        return 'Số dư không đủ! Hiện có: ${currentBalance.toStringAsFixed(0)}₫';
      }
    }

    state = state.copyWith(isSaving: true);

    try {
      String? imageUrl;
      if (state.receiptImage != null) {
        imageUrl = await CloudinaryService.uploadImage(state.receiptImage!);
        if (imageUrl == null) return 'Lỗi tải ảnh lên, vui lòng thử lại!';
      }

      await RTDBService().saveTransaction(
        uid: uid,
        walletId: state.selectedWalletId!,
        amount: amount,
        category: state.selectedCategory,
        name: name,
        isExpense: state.isExpense,
        imgUrl: imageUrl,
      );

      return null; // null = thành công
    } catch (_) {
      return 'Đã xảy ra lỗi, thử lại!';
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

// --- Provider ---
final addTransactionProvider =
StateNotifierProvider.autoDispose<AddTransactionNotifier, AddTransactionState>(
      (ref) => AddTransactionNotifier(),
);