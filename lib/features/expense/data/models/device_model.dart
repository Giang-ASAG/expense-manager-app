// lib/core/local/models/device_model.dart

class DeviceModel {
  final String deviceId;
  final String deviceName;
  final String osVersion;
  final String? fcmToken;
  final int lastLogin;
  final String userId;

  const DeviceModel({
    required this.deviceId,
    required this.deviceName,
    required this.osVersion,
    this.fcmToken,
    required this.lastLogin,
    required this.userId,
  });

  Map<String, dynamic> toMap() => {
    'device_id': deviceId,
    'device_name': deviceName,
    'os_version': osVersion,
    'fcm_token': fcmToken,
    'last_login': lastLogin,
    'user_id': userId,
  };

  factory DeviceModel.fromMap(Map<String, dynamic> map) => DeviceModel(
    deviceId: map['device_id'] as String,
    deviceName: map['device_name'] as String,
    osVersion: map['os_version'] as String,
    fcmToken: map['fcm_token'] as String?,
    lastLogin: map['last_login'] as int,
    userId: map['user_id'] as String,
  );

  DeviceModel copyWith({
    String? fcmToken,
    int? lastLogin,
  }) =>
      DeviceModel(
        deviceId: deviceId,
        deviceName: deviceName,
        osVersion: osVersion,
        fcmToken: fcmToken ?? this.fcmToken,
        lastLogin: lastLogin ?? this.lastLogin,
        userId: userId,
      );
}