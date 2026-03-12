import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../domain/models/plato.dart';

class PlatoService {
  final http.Client _client;

  PlatoService({http.Client? client}) : _client = client ?? http.Client();

  static final Map<int, Plato> _cachePorId = {};

  Future<Plato> obtenerPorId(int platoId) async {
    final cached = _cachePorId[platoId];
    if (cached != null) {
      return cached;
    }

    final baseUrl = Env.baseUrl;

    if (baseUrl.isEmpty) {
      throw Exception('La baseUrl del backend no está configurada');
    }

    final uri = Uri.parse('$baseUrl/platos/$platoId');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error al cargar plato (${response.statusCode})');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final plato = Plato.fromJson(data);
    _cachePorId[platoId] = plato;
    return plato;
  }
}
