// lib\presentation\screens\detail_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/api.dart';
import '../../data/models/user_model.dart';
import '../widgets/custom_text_field.dart';

class DetailScreen extends StatefulWidget {
  final UserModel user;

  const DetailScreen({super.key, required this.user});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _passwordController.text = user.password;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildImage() {
    final user = widget.user;
    if (user.image != null && user.image!.isNotEmpty) {
      String imageUrl;
      if (user.image!.startsWith('/assets/')) {
        imageUrl = '${ApiConstants.baseUrl}${user.image}';
      } else {
        imageUrl = '${ApiConstants.assetUrl}/${user.image}';
      }

      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 420,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.person, size: 100, color: Colors.deepPurple),
        ),
      );
    }

    return const Center(
      child: Icon(Icons.person, size: 100, color: Colors.deepPurple),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Chi tiết người dùng',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 420,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildImage(),
                ),
              ),
              const SizedBox(height: 32),

              // ✅ Dùng lại CustomTextField (readOnly)
              CustomTextField(
                controller: _usernameController,
                label: 'Tên người dùng',
                icon: Icons.person,
                readOnly: true,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                readOnly: true,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _passwordController,
                label: 'Mật khẩu',
                icon: Icons.lock_outline,
                isPassword: true,
                readOnly: true, // 🔥 có thể ẩn/hiện mật khẩu
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Quay lại',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
