import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../domain/models/configuracion.dart';

class ConfiguracionService {
  final http.Client _client;

  ConfiguracionService({http.Client? client})
    : _client = client ?? http.Client();

  static Configuracion? _cachePrimera;

  Future<Configuracion> obtenerPrimera() async {
    if (_cachePrimera != null) {
      return _cachePrimera!;
    }

    final baseUrl = Env.baseUrl;

    if (baseUrl.isEmpty) {
      throw Exception('La baseUrl del backend no está configurada');
    }

    final uri = Uri.parse('$baseUrl/configuraciones/first');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error al cargar configuración (${response.statusCode})');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final configuracion = Configuracion.fromJson(data);
    _cachePrimera = configuracion;
    return configuracion;
  }
}
