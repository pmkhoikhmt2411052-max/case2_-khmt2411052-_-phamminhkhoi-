import '../tasks/task_list_screen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.post('/auth/login', {
        'email': _emailController.text,
        'password': _passwordController.text,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await ApiClient.saveToken(data['token']);
        
        if (mounted) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TaskListScreen())); }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sai email hoặc mật khẩu')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu')),
            const SizedBox(height: 24),
            _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _login, child: const Text('Đăng nhập')),
          ],
        ),
      ),
    );
  }
}