abstract class AppConstants {
  static const List<Map<String, dynamic>> defaultCategories = [
    // CHI PHÍ
    {
      'name': 'Ăn uống',
      'icon': 'restaurant',
      'color': 0xFFFFA500,
      'isExpense': true,
    },
    {
      'name': 'Giải trí',
      'icon': 'movie',
      'color': 0xFFFFC0CB,
      'isExpense': true,
    },
    {
      'name': 'Di chuyển',
      'icon': 'car',
      'color': 0xFF2196F3,
      'isExpense': true,
    },
    {
      'name': 'Mua sắm',
      'icon': 'shopping',
      'color': 0xFF9C27B0,
      'isExpense': true,
    },

    // THU NHẬP
    {
      'name': 'Tiền lương',
      'icon': 'money',
      'color': 0xFF4CAF50,
      'isExpense': false,
    },
    {
      'name': 'Tiền thưởng',
      'icon': 'redeem',
      'color': 0xFFFFD700,
      'isExpense': false,
    },
    {
      'name': 'Đầu tư',
      'icon': 'trending',
      'color': 0xFF2196F3,
      'isExpense': false,
    },
    {
      'name': 'Ngân hàng',
      'icon': 'bank',
      'color': 0xFF9E9E9E,
      'isExpense': false,
    },
  ];
}
