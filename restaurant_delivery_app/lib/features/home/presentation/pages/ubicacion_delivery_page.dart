import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../auth/domain/models/delivery.dart';
import '../../services/delivery_service.dart';
import 'home_page.dart';

class UbicacionDeliveryPage extends StatefulWidget {
  final Delivery delivery;

  const UbicacionDeliveryPage({
    super.key,
    required this.delivery,
  });

  @override
  State<UbicacionDeliveryPage> createState() => _UbicacionDeliveryPageState();
}

class _UbicacionDeliveryPageState extends State<UbicacionDeliveryPage> {
  final DeliveryService _deliveryService = DeliveryService();

  LatLng? _initialPosition;
  LatLng? _selectedPosition;
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _initPosition();
  }

  Future<void> _initPosition() async {
    LatLng? position;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final current = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          position = LatLng(current.latitude, current.longitude);
        }
      }
    } catch (_) {
      position = null;
    }

    if (position == null) {
      position = _parseUbicacion(widget.delivery.ubicacion);
    }

    setState(() {
      _initialPosition = position;
      _selectedPosition = position;
      _cargando = false;
    });
  }

  LatLng _parseUbicacion(String ubicacion) {
    try {
      final parts = ubicacion.split(',');
      final lat = double.parse(parts[0].trim());
      final lon = double.parse(parts[1].trim());
      return LatLng(lat, lon);
    } catch (_) {
      return LatLng(-17.7833, -63.1821);
    }
  }

  Future<void> _guardarUbicacion() async {
    if (_selectedPosition == null || _initialPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo determinar la ubicación')),
      );
      return;
    }

    if (_guardando) return;

    setState(() {
      _guardando = true;
    });

    final ubicacion =
        '${_selectedPosition!.latitude},${_selectedPosition!.longitude}';

    try {
      final actualizado = await _deliveryService.actualizarPerfil(
        id: widget.delivery.id,
        nombre: widget.delivery.nombre,
        ubicacion: ubicacion,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicación actualizada')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(delivery: actualizado),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo actualizar la ubicación')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(),
              const SizedBox(height: 12),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                'MODIFICAR UBICACIÓN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: _cargando || _initialPosition == null
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: _selectedPosition!,
                                    initialZoom: 15,
                                    onTap: (tapPosition, point) {
                                      setState(() {
                                        _selectedPosition = point;
                                      });
                                    },
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName:
                                          'com.example.restaurant_delivery_app',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        if (_selectedPosition != null)
                                          Marker(
                                            point: _selectedPosition!,
                                            width: 40,
                                            height: 40,
                                            child: const Icon(
                                              Icons.location_on,
                                              size: 40,
                                              color: AppColors.secundary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedPosition == null
                                        ? 'Selecciona un punto en el mapa'
                                        : 'Ubicación seleccionada: ${_selectedPosition!.latitude.toStringAsFixed(5)}, ${_selectedPosition!.longitude.toStringAsFixed(5)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _guardando
                                          ? null
                                          : _guardarUbicacion,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.secundary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                      ),
                                      child: Text(
                                        _guardando
                                            ? 'GUARDANDO...'
                                            : 'CAMBIAR UBICACIÓN',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

