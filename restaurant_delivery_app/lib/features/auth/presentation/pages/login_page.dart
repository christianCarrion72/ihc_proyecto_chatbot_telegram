import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:restaurant_delivery_app/shared/widgets/auth_text_field.dart';
import 'package:restaurant_delivery_app/shared/widgets/primary_button.dart';

import '../../../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../domain/models/delivery.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Completa correo y contraseña');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.login(email, password);
      final statusCode = response.statusCode;

      if (statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final delivery = Delivery.fromJson(data);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomePage(delivery: delivery)),
        );
      } else if (statusCode == 401) {
        _showSnackBar('Credenciales incorrectas');
      } else {
        _showSnackBar('Error al iniciar sesión ($statusCode)');
      }
    } catch (e) {
      _showSnackBar('No se pudo conectar con el servidor');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.secundary,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'DELI GO',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tu comida en casa',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 48),
                AuthTextField(
                  controller: _emailController,
                  hintText: 'Correo electronico',
                  icon: Icons.lock_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  controller: _passwordController,
                  hintText: 'Contraseña',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'INICIAR SESION',
                  isLoading: _isLoading,
                  onPressed: _login,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}