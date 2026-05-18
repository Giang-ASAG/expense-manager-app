import 'dart:convert';
import 'package:http/http.dart' as http;

class BankModel {
  final int id;
  final String name;
  final String code;
  final String? bin;
  final String? logo;

  BankModel({
    required this.id,
    required this.name,
    required this.code,
    this.bin,
    this.logo,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      bin: json['bin'],
      logo: json['logo'],
    );
  }

  @override
  String toString() => name;
}

class BanksService {
  static const String _baseUrl = 'https://api.vietqr.io/v2/banks';
  static List<BankModel>? _cachedBanks;

  /// Lấy danh sách ngân hàng từ API hoặc cache
  static Future<List<BankModel>> getBanks({bool forceRefresh = false}) async {
    try {
      // Nếu có cache và không force refresh, trả về cache
      if (_cachedBanks != null && !forceRefresh) {
        print('✅ Using cached banks (${_cachedBanks!.length} items)');
        return _cachedBanks!;
      }

      print('🔵 Fetching banks from API...');

      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData is! Map || jsonData['code'] != '00') {
          throw Exception('Invalid response format');
        }

        final List<dynamic> data = jsonData['data'] ?? [];
        _cachedBanks = data
            .map((bank) => BankModel.fromJson(bank as Map<String, dynamic>))
            .toList();

        print('✅ Fetched ${_cachedBanks!.length} banks successfully');
        return _cachedBanks!;
      } else {
        throw Exception('Failed to load banks: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching banks: $e');

      // Trả về danh sách mặc định nếu lỗi
      return _getDefaultBanks();
    }
  }

  /// Danh sác1ỗi)
  static List<BankModel> _getDefaultBanks() {
    return [
      BankModel(
        id: 1,
        name:
            'Ngân hàng TNHH MTV Công Ty Cổ Phần Ngân Hàng Thương Mại Cổ Phần Vietcombank',
        code: 'VCB',
        bin: '970436',
      ),
      BankModel(
        id: 2,
        name:
            'Ngân hàng TNHH MTV Công Ty Cổ Phần Ngân Hàng Thương Mại Cổ Phần Techcombank',
        code: 'TCB',
        bin: '970407',
      ),
      BankModel(
        id: 3,
        name:
            'Ngân hàng TNHH MTV Công Ty Cổ Phần Ngân Hàng Thương Mại Cổ Phần MB Bank',
        code: 'MBB',
        bin: '970422',
      ),
      BankModel(
        id: 4,
        name:
            'Ngân hàng TNHH MTV Công Ty Cổ Phần Ngân Hàng Thương Mại Cổ Phần ACB',
        code: 'ACB',
        bin: '970416',
      ),
      BankModel(
        id: 5,
        name:
            'Ngân hàng TNHH MTV Công Ty Cổ Phần Ngân Hàng Thương Mại Cổ Phần TPBank',
        code: 'TPB',
        bin: '970423',
      ),
      BankModel(id: 6, name: 'Tiền mặt', code: 'CASH', bin: '000000'),
    ];
  }

  /// Tìm kiếm ngân hàng theo tên
  static Future<List<BankModel>> searchBanks(String query) async {
    if (query.isEmpty) {
      return getBanks();
    }

    final banks = await getBanks();
    final lowerQuery = query.toLowerCase();

    return banks
        .where(
          (bank) =>
              bank.name.toLowerCase().contains(lowerQuery) ||
              bank.code.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Clear cache
  static void clearCache() {
    _cachedBanks = null;
    print('✅ Banks cache cleared');
  }
}
