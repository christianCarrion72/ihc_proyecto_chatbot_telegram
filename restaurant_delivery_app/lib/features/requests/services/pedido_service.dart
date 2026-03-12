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

    return data.map((e) => Pedido.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Pedido> actualizarEstado(int pedidoId, String estado) async {
    final baseUrl = Env.baseUrl;

    if (baseUrl.isEmpty) {
      throw Exception('La baseUrl del backend no está configurada');
    }

    final uri = Uri.parse('$baseUrl/pedidos/$pedidoId');

    final response = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'estado': estado}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar estado (${response.statusCode})');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    return Pedido.fromJson(data);
  }

  Future<Pedido> cancelar(int pedidoId, String motivo) async {
    final baseUrl = Env.baseUrl;

    if (baseUrl.isEmpty) {
      throw Exception('La baseUrl del backend no está configurada');
    }

    final uri = Uri.parse('$baseUrl/pedidos/$pedidoId/cancelar');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'motivo': motivo}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al cancelar pedido (${response.statusCode})');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    return Pedido.fromJson(data);
  }
}
