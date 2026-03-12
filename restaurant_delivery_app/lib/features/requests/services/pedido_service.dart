import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../domain/models/pedido.dart';

class PedidoService {
  final http.Client _client;

  PedidoService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Pedido>> obtenerPorDelivery(int deliveryId) async {
    final baseUrl = Env.baseUrl;

    if (baseUrl.isEmpty) {
      throw Exception('La baseUrl del backend no está configurada');
    }

    final uri = Uri.parse('$baseUrl/pedidos/delivery/$deliveryId');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error al cargar pedidos (${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((e) => Pedido.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

