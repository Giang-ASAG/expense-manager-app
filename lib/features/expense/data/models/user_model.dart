class UserModel {
  final String uid;
  final String email;
  final String photoUrl;
  final String createdAt; // Dùng String để dễ lưu JSON
  final String currency;

  UserModel({
    required this.uid,
    required this.email,
    required this.photoUrl,
    required this.createdAt,
    this.currency = 'USD',
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'photo_url': photoUrl,
      'created_at': createdAt,
      'currency': currency,
    };
  }
}