import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  final http.Client _client;

  RouteService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<LatLng>> obtenerRuta(LatLng origen, LatLng destino) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origen.longitude},${origen.latitude};'
      '${destino.longitude},${destino.latitude}'
      '?overview=full&geometries=geojson',
    );

    final response = await _client.get(url);

    if (response.statusCode != 200) {
      return [origen, destino];
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final routes = data['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      return [origen, destino];
    }

    final geometry = routes[0]['geometry'] as Map<String, dynamic>?;
    if (geometry == null) {
      return [origen, destino];
    }

    final coordinates = geometry['coordinates'] as List<dynamic>?;
    if (coordinates == null || coordinates.isEmpty) {
      return [origen, destino];
    }

    return coordinates
        .map(
          (c) => LatLng(
            (c[1] as num).toDouble(),
            (c[0] as num).toDouble(),
          ),
        )
        .toList();
  }
}

