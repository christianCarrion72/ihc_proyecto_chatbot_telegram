import 'package:flutter/material.dart';
import 'package:restaurant_delivery_app/features/auth/presentation/pages/login_page.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RestaurantDeliveryApp());
}

class RestaurantDeliveryApp extends StatelessWidget {
  const RestaurantDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant Delivery',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Delivery'),
      ),
      body: const Center(
        child: Text(
          'App iniciada correctamente',
        ),
      ),
    );
  }
}