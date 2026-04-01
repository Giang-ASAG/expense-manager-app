import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon; // Lưu tên icon dưới dạng String (vd: 'restaurant')
  final int colorValue; // Lưu mã màu dưới dạng int (vd: 0xFFFFA500)
  final bool isExpense; // Thêm trường này

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.isExpense,
  });

  // Chuyển từ Map (Firebase) sang Model
  factory CategoryModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'category',
      colorValue: map['color'] is int
          ? map['color']
          : int.parse(map['color'].toString()),
      isExpense: map['isExpense'] ?? true, // Mặc định là chi phí
    );
  }

  // Chuyển từ Model sang Map để lưu lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'color': colorValue,
      'isExpense': isExpense,
    };
  }

  // Helper để lấy đối tượng Color từ colorValue
  Color get color => Color(colorValue);

  // Helper để lấy IconData từ chuỗi icon (ánh xạ thủ công)
  IconData get iconData {
    switch (icon) {
      case 'restaurant':
        return Icons.restaurant;
      case 'coffee':
        return Icons.coffee;
      case 'pizza':
        return Icons.local_pizza;
      case 'movie':
        return Icons.movie;
      case 'car':
        return Icons.directions_car;
      case 'gas':
        return Icons.local_gas_station;
      case 'bike':
        return Icons.directions_bike;
      case 'bus':
        return Icons.directions_bus;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bill':
        return Icons.receipt_long;
      case 'medical':
        return Icons.medical_services;
      case 'school':
        return Icons.school;
      case 'bank':
        return Icons.account_balance;
      case 'money':
        return Icons.attach_money;
      // legacy keys (phòng trường hợp dữ liệu cũ)
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'receipt':
        return Icons.receipt;
      case 'transfer':
        return Icons.swap_horiz;
      case 'medical_services':
        return Icons.medical_services;
      case 'redeem':
        return Icons.redeem;
      case 'trending':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }
  static CategoryModel get transferCategory => CategoryModel(
    id: 'transfer',
    name: 'Chuyển tiền',
    icon: 'transfer',
    colorValue: 0xFF2196F3, // màu xanh dương
    isExpense: true,
  );
}
