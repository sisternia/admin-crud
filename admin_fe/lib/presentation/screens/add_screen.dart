// lib/presentation/screens/add_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../../core/constants/api.dart';
import '../../core/constants/validator.dart';
import '../widgets/custom_text_field.dart';
import 'dart:convert';
import '../../data/models/user_model.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _webImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImage = pickedFile;
          _webImage = bytes;
        });
      } else {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    }
  }

  Future<void> _submit() async {
    final userError = Validator.validateUsername(_userController.text);
    final emailError = Validator.validateEmail(_emailController.text);
    final passError = Validator.validatePassword(_passwordController.text);

    if (userError != null || emailError != null || passError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userError ?? emailError ?? passError!),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var uri = Uri.parse(ApiConstants.users);
      var request = http.MultipartRequest('POST', uri);

      UserModel user = UserModel(
        username: _userController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      request.fields.addAll(user.toJson().map((key, value) =>
          MapEntry(key, value != null ? value.toString() : '')));

      if (_selectedImage != null) {
        if (kIsWeb && _webImage != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'image',
            _webImage!,
            filename: p.basename(_selectedImage!.name),
          ));
        } else if (!kIsWeb) {
          request.files.add(await http.MultipartFile.fromPath(
            'image',
            _selectedImage!.path,
            filename: p.basename(_selectedImage!.path),
          ));
        }
      }

      var response = await request.send();
      var respStr = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm user thành công')));
        Navigator.pop(context);
      } else {
        var data = jsonDecode(respStr);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi: ${data['message']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildImage() {
    if (_selectedImage == null) {
      return const Center(
        child: Icon(Icons.person, size: 100, color: Colors.deepPurple),
      );
    } else if (kIsWeb && _webImage != null) {
      return Image.memory(_webImage!,
          width: double.infinity, height: 420, fit: BoxFit.cover);
    } else {
      return Image.file(File(_selectedImage!.path),
          width: double.infinity, height: 420, fit: BoxFit.cover);
    }
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
                'Thêm người dùng',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: double.infinity,
                    height: 420,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildImage(),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            color: Colors.deepPurple, size: 26),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              CustomTextField(
                  controller: _userController,
                  label: 'User',
                  icon: Icons.person),
              const SizedBox(height: 16),
              CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email),
              const SizedBox(height: 16),
              CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  isPassword: true),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Xác nhận',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
