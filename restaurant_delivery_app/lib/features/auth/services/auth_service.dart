import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> login(String email, String password) async {
    final baseUrl = Env.baseUrl;

    if (baseUrl.isEmpty) {
      throw Exception('BACKEND_BASE_URL no está configurada');
    }

    final url = Uri.parse('$baseUrl/deliveries/login');

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return response;
  }
}
