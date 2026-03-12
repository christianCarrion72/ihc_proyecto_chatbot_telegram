import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/route_map.dart';
import '../../domain/models/pedido.dart';
import '../../domain/models/detalle.dart';
import '../../domain/models/plato.dart';
import '../../services/pedido_service.dart';
import '../../services/detalle_service.dart';
import '../../services/plato_service.dart';
import 'viaje_iniciado_page.dart';

class PedidoDetallePage extends StatefulWidget {
  final Pedido pedido;
  final void Function(int) onChangeTab;

  const PedidoDetallePage({
    super.key,
    required this.pedido,
    required this.onChangeTab,
  });

  @override
  State<PedidoDetallePage> createState() => _PedidoDetallePageState();
}

class _PedidoDetallePageState extends State<PedidoDetallePage> {
  final DetalleService _detalleService = DetalleService();
  final PlatoService _platoService = PlatoService();
  final PedidoService _pedidoService = PedidoService();

  late Future<List<_DetalleConNombre>> _futureDetalles;
  bool _iniciandoViaje = false;

  @override
  void initState() {
    super.initState();
    _futureDetalles = _cargarDetallesConNombre();
  }

  Future<List<_DetalleConNombre>> _cargarDetallesConNombre() async {
    final detalles = await _detalleService.obtenerPorPedido(widget.pedido.id);

    final ids = detalles.map((d) => d.platoId).toSet();

    final Map<int, Plato> platos = {};

    for (final id in ids) {
      platos[id] = await _platoService.obtenerPorId(id);
    }

    return detalles
        .map(
          (d) => _DetalleConNombre(
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
              const SizedBox(height: 8),
              const Text(
                'DETALLES DEL PEDIDO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 20),
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.fastfood,
                              size: 48,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Pedido ${_codigoPedido()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        RouteMap(destinoCoords: widget.pedido.ubicacionEntrega),
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
                          child: FutureBuilder<List<_DetalleConNombre>>(
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
                        const SizedBox(height: 12),
                        Builder(
                          builder: (context) {
                            final estado = widget.pedido.estado
                                .toLowerCase()
                                .trim();
                            final esEntregado = estado == 'entregado';
                            final esCancelado = estado == 'cancelado';
                            final puedeIniciarViaje = estado == 'en local';

                            if (esEntregado || esCancelado) {
                              return Center(
                                child: Text(
                                  esEntregado
                                      ? 'El pedido fue entregado'
                                      : 'El pedido fue cancelado',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                              );
                            }

                            if (!puedeIniciarViaje) {
                              return const SizedBox.shrink();
                            }

                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _iniciandoViaje
                                    ? null
                                    : () async {
                                        setState(() {
                                          _iniciandoViaje = true;
                                        });
                                        try {
                                          final actualizado =
                                              await _pedidoService
                                                  .actualizarEstado(
                                                    widget.pedido.id,
                                                    'en camino',
                                                  );
                                          if (!mounted) return;
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (_) => ViajeIniciadoPage(
                                                pedido: actualizado,
                                                onChangeTab: widget.onChangeTab,
                                              ),
                                            ),
                                          );
                                        } catch (_) {
                                          if (mounted) {
                                            setState(() {
                                              _iniciandoViaje = false;
                                            });
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secundary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: const Text(
                                  'INICIAR VIAJE',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
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

class _DetalleConNombre {
  final int cantidad;
  final String observacion;
  final String nombrePlato;

  _DetalleConNombre({
    required this.cantidad,
    required this.observacion,
    required this.nombrePlato,
  });
}
