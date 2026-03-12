import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../features/requests/services/configuracion_service.dart';
import '../../features/requests/services/route_service.dart';

class RouteMap extends StatefulWidget {
  final String destinoCoords;

  const RouteMap({super.key, required this.destinoCoords});

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  final ConfiguracionService _configuracionService = ConfiguracionService();
  final RouteService _routeService = RouteService();
  late Future<_RouteData> _futureRoute;

  @override
  void initState() {
    super.initState();
    _futureRoute = _cargarRuta();
  }

  Future<_RouteData> _cargarRuta() async {
    final configuracion = await _configuracionService.obtenerPrimera();

    final origen = _parseCoords(configuracion.ubicacionRestaurante);
    final destino = _parseCoords(widget.destinoCoords);

    if (origen == null || destino == null) {
      throw Exception('Coordenadas inválidas');
    }

    final routePoints = await _routeService.obtenerRuta(origen, destino);

    final allPoints = <LatLng>[origen, destino, ...routePoints];

    final center = LatLngBounds.fromPoints(allPoints).center;

    return _RouteData(
      origen: origen,
      destino: destino,
      center: center,
      routePoints: routePoints,
    );
  }

  LatLng? _parseCoords(String value) {
    try {
      final parts = value.split(',');
      if (parts.length != 2) return null;
      final lat = double.parse(parts[0]);
      final lon = double.parse(parts[1]);
      return LatLng(lat, lon);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: FutureBuilder<_RouteData>(
          future: _futureRoute,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.map, color: Colors.grey, size: 48),
                ),
              );
            }

            final data = snapshot.data!;

            final bounds = LatLngBounds.fromPoints([
              data.origen,
              data.destino,
              ...data.routePoints,
            ]);

            return FlutterMap(
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(24),
                ),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.restaurantDeliveryApp',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: data.routePoints.isNotEmpty
                          ? data.routePoints
                          : [data.origen, data.destino],
                      strokeWidth: 4,
                      color: Colors.green,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: data.origen,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.storefront, color: Colors.red),
                    ),
                    Marker(
                      point: data.destino,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin, color: Colors.blue),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RouteData {
  final LatLng origen;
  final LatLng destino;
  final LatLng center;
  final List<LatLng> routePoints;

  _RouteData({
    required this.origen,
    required this.destino,
    required this.center,
    required this.routePoints,
  });
}
