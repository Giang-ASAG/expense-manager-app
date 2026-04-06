import 'package:flutter/material.dart';

class OnboardingContent extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingContent({
    Key? key,
    required this.title,
    required this.description,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          imagePath, // Biến này phải khớp với 'assets/images/logo_app.png'
          width: 300,
          height: 300,
          fit: BoxFit.contain,
          // Thêm cái này để debug: nếu lỗi nó sẽ hiện icon báo lỗi
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red, size: 100);
          },
        ),
        const SizedBox(height: 40),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
