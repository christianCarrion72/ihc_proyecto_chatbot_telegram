import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../domain/models/detalle.dart';

class DetalleService {
  final http.Client _client;

  DetalleService({http.Client? client}) : _client = client ?? http.Client();

  static final Map<int, List<Detalle>> _cachePorPedido = {};

  Future<List<Detalle>> obtenerPorPedido(int pedidoId) async {
    final cached = _cachePorPedido[pedidoId];
    if (cached != null) {
      return cached;
    }

    final baseUrl = Env.baseUrl;

    if (baseUrl.isEmpty) {
      throw Exception('La baseUrl del backend no está configurada');
    }

    final uri = Uri.parse('$baseUrl/detalles/pedido/$pedidoId');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error al cargar detalles (${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    final detalles = data
        .map((e) => Detalle.fromJson(e as Map<String, dynamic>))
        .toList();

    _cachePorPedido[pedidoId] = detalles;

    return detalles;
  }
}
