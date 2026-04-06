import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:expense_manager_app/features/expense/data/models/device_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:expense_manager_app/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();

  factory DeviceService() => _instance;

  DeviceService._internal();

  final _deviceInfo = DeviceInfoPlugin();
  final _dbHelper = DatabaseHelper(); // Khởi tạo helper

  /// Gọi khi đăng nhập thành công
  Future<void> onLogin(String userId) async {
    try {
      final info = await _getDeviceInfo();
      final fcmToken = await FirebaseMessaging.instance.getToken();

      // Tạo đối tượng Model từ thông tin lấy được
      final device = DeviceModel(
        deviceId: info['deviceId']!,
        deviceName: info['deviceName']!,
        osVersion: info['osVersion']!,
        fcmToken: fcmToken,
        lastLogin: DateTime.now().millisecondsSinceEpoch,
        userId: userId,
      );

      // Lưu vào SQLite
      await _saveToLocal(device);

      print('--- DeviceService: Đã cập nhật thiết bị ${device.deviceName} ---');
    } catch (e) {
      print('DeviceService.onLogin error: $e');
    }
  }

  // Hàm nội bộ để insert vào DB
  Future<void> _saveToLocal(DeviceModel device) async {
    final db = await _dbHelper.database;
    await db.insert(
      'devices',
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm
          .replace, // Nếu trùng ID máy thì cập nhật bản mới nhất
    );
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    if (Platform.isAndroid) {
      final android = await _deviceInfo.androidInfo;
      return {
        'deviceId': android.id,
        'deviceName': '${android.brand} ${android.model}',
        'osVersion': 'Android ${android.version.release}',
      };
    } else if (Platform.isIOS) {
      final ios = await _deviceInfo.iosInfo;
      return {
        'deviceId': ios.identifierForVendor ?? 'unknown',
        'deviceName': ios.utsname.machine,
        'osVersion': 'iOS ${ios.systemVersion}',
      };
    }
    return {
      'deviceId': 'unknown',
      'deviceName': 'Unknown Device',
      'osVersion': 'Unknown OS',
    };
  }
}
