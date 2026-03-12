import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/route_map.dart';
import '../../domain/models/pedido.dart';
import '../../domain/models/detalle.dart';
import '../../domain/models/plato.dart';
import '../../services/pedido_service.dart';
import '../../services/detalle_service.dart';
import '../../services/plato_service.dart';
import 'entrega_completa_page.dart';
import 'cancelar_pedido_page.dart';

class ViajeIniciadoPage extends StatefulWidget {
  final Pedido pedido;
  final void Function(int) onChangeTab;

  const ViajeIniciadoPage({
    super.key,
    required this.pedido,
    required this.onChangeTab,
  });

  @override
  State<ViajeIniciadoPage> createState() => _ViajeIniciadoPageState();
}

class _ViajeIniciadoPageState extends State<ViajeIniciadoPage> {
  final DetalleService _detalleService = DetalleService();
  final PlatoService _platoService = PlatoService();
  final PedidoService _pedidoService = PedidoService();

  late Future<List<_DetalleViaje>> _futureDetalles;
  bool _finalizando = false;

  @override
  void initState() {
    super.initState();
    _futureDetalles = _cargarDetallesConNombre();
  }

  Future<List<_DetalleViaje>> _cargarDetallesConNombre() async {
    final detalles = await _detalleService.obtenerPorPedido(widget.pedido.id);

    final ids = detalles.map((d) => d.platoId).toSet();

    final Map<int, Plato> platos = {};

    for (final id in ids) {
      platos[id] = await _platoService.obtenerPorId(id);
    }

    return detalles
        .map(
          (d) => _DetalleViaje(
            cantidad: d.cantidad,
            observacion: d.observacion,
            nombrePlato: platos[d.platoId]?.nombre ?? 'Plato',
          ),
        )
        .toList();
  }

  String _codigoPedido() {
    final padded = widget.pedido.id.toString().padLeft(4, '0');
    return '#DG-$padded';
  }

  Future<void> _abrirGoogleMaps() async {
    final parts = widget.pedido.ubicacionEntrega.split(',');
    if (parts.length != 2) return;

    final lat = double.tryParse(parts[0]);
    final lon = double.tryParse(parts[1]);
    if (lat == null || lon == null) return;

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _marcarLlegue() async {
    if (_finalizando) return;
    setState(() {
      _finalizando = true;
    });
    try {
      final actualizado = await _pedidoService.actualizarEstado(
        widget.pedido.id,
        'en destino',
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EntregaCompletaPage(
            pedido: actualizado,
            onChangeTab: widget.onChangeTab,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _finalizando = false;
        });
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
              Row(
                children: [
                  const Expanded(child: AppHeader()),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CancelarPedidoPage(
                              pedido: widget.pedido,
                              onChangeTab: widget.onChangeTab,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                  padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'VIAJE INICIADO',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secundary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        RouteMap(destinoCoords: widget.pedido.ubicacionEntrega),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Ruta al destino',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '12 min | 3.5 km',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Dirección de Entrega',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.pedido.direccionEntrega ??
                              widget.pedido.ubicacionEntrega,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cliente: ${widget.pedido.nombreUsuario}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Platos:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: FutureBuilder<List<_DetalleViaje>>(
                            future: _futureDetalles,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (snapshot.hasError) {
                                return const Text(
                                  'No se pudieron cargar los detalles',
                                  style: TextStyle(fontSize: 14),
                                );
                              }

                              final detalles = snapshot.data ?? [];

                              if (detalles.isEmpty) {
                                return const Text(
                                  'Este pedido no tiene detalles',
                                  style: TextStyle(fontSize: 14),
                                );
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.only(
                                  bottom: 72,
                                  top: 4,
                                ),
                                itemCount: detalles.length,
                                itemBuilder: (context, index) {
                                  final d = detalles[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      '${d.cantidad} x ${d.nombrePlato}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _abrirGoogleMaps,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: const Text(
                              'NAVEGAR CON GOOGLE MAPS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _finalizando ? null : _marcarLlegue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secundary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: const Text(
                              'LLEGUÉ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.secundary,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            widget.onChangeTab(0);
          } else if (index == 1) {
            widget.onChangeTab(1);
          } else if (index == 2) {
            widget.onChangeTab(2);
          }
          Navigator.of(context).pop();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Principal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _DetalleViaje {
  final int cantidad;
  final String observacion;
  final String nombrePlato;

  _DetalleViaje({
    required this.cantidad,
    required this.observacion,
    required this.nombrePlato,
  });
}
