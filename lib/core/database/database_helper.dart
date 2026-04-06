import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // 1. Lấy đường dẫn thư mục database trên thiết bị (Android/iOS)
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "vikhon_db.db");

    // 2. Kiểm tra xem file đã tồn tại ở đó chưa
    var exists = await databaseExists(path);

    if (!exists) {
      // Nếu chưa có (lần đầu mở app), tiến hành copy từ Assets sang
      print("--- Đang copy database từ assets sang hệ thống... ---");

      try {
        // Tạo thư mục nếu chưa có
        await Directory(dirname(path)).create(recursive: true);

        // Đọc file từ assets (Dùng đúng đường dẫn anh đã đặt)
        ByteData data = await rootBundle.load(join("assets/db/vikhon_db.db"));
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

        // Ghi file ra bộ nhớ máy
        await File(path).writeAsBytes(bytes, flush: true);
        print("--- Copy thành công! ---");
      } catch (e) {
        print("--- Lỗi khi copy database: $e ---");
      }
    } else {
      print("--- Database đã tồn tại, tiến hành mở... ---");
    }

    // 3. Mở database để sử dụng
    return await openDatabase(path, readOnly: false);
  }
}