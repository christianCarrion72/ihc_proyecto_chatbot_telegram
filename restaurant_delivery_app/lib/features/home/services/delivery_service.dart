import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../../auth/domain/models/delivery.dart';

class DeliveryService {
  final http.Client _client;

  DeliveryService({http.Client? client}) : _client = client ?? http.Client();

  Future<Delivery> actualizarDisponibilidad(int id, bool disponible) async {
    final baseUrl = Env.baseUrl;
    if (baseUrl.isEmpty) {
      throw Exception('Env.baseUrl no está configurada');
    }

    final url = Uri.parse('$baseUrl/deliveries/$id');

    final response = await _client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'disponible': disponible}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error actualizando disponibilidad (${response.statusCode})');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return Delivery.fromJson(data);
  }
}

