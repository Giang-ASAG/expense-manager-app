import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  static final _cloudinary = CloudinaryPublic(
    'dsxigomwu',
    'vikhon_preset',
    cache: false,
  );

  static Future<String?> uploadImage(File imageFile) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          // Tạm thời bỏ dòng folder để test cấu hình gốc của preset
        ),
      );
      debugPrint("URL Img ${response.secureUrl}");
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      // Đoạn này sẽ in ra lỗi thật sự như: "Invalid Cloud Name" hoặc "Invalid Upload Preset"
      print("Lỗi từ Cloudinary: ${e.message}");
      return null;
    } catch (e) {
      print("Lỗi hệ thống: $e");
      return null;
    }
  }
}
