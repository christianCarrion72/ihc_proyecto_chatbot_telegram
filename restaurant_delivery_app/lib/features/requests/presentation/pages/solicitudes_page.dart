import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../auth/domain/models/delivery.dart';
import '../../domain/models/pedido.dart';
import '../../services/pedido_service.dart';
import 'pedido_detalle_page.dart';
import 'viaje_iniciado_page.dart';
import 'entrega_completa_page.dart';

class SolicitudesPage extends StatefulWidget {
  final Delivery delivery;
  final void Function(int) onChangeTab;

  const SolicitudesPage({
    super.key,
    required this.delivery,
    required this.onChangeTab,
  });

  @override
  State<SolicitudesPage> createState() => _SolicitudesPageState();
}

class _SolicitudesPageState extends State<SolicitudesPage> {
  final PedidoService _pedidoService = PedidoService();
  late Future<List<Pedido>> _futurePedidos;
  int? _expandedPedidoId;

  Future<void> _handleVerPedido(Pedido pedido) async {
    final estado = pedido.estado.toLowerCase();

    final page = estado == 'en camino'
        ? ViajeIniciadoPage(pedido: pedido, onChangeTab: widget.onChangeTab)
        : estado == 'en destino'
        ? EntregaCompletaPage(pedido: pedido, onChangeTab: widget.onChangeTab)
        : PedidoDetallePage(pedido: pedido, onChangeTab: widget.onChangeTab);

    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    setState(() {
      _futurePedidos = _pedidoService.obtenerPorDelivery(widget.delivery.id);
    });
  }

  @override
  void initState() {
    super.initState();
    _futurePedidos = _pedidoService.obtenerPorDelivery(widget.delivery.id);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(),
            const SizedBox(height: 32),
            const Text(
              'PEDIDOS ASIGNADOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Pedido>>(
              future: _futurePedidos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                      'No se pudieron cargar las solicitudes',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                final pedidos = List<Pedido>.from(snapshot.data ?? []);

                pedidos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (pedidos.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                      'No tienes pedidos asignados por ahora',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                return Column(
                  children: List.generate(pedidos.length, (index) {
                    final pedido = pedidos[index];
                    return _PedidoCard(
                      pedido: pedido,
                      esNuevo: index == 0,
                      expandido: _expandedPedidoId == pedido.id,
                      onTap: () {
                        setState(() {
                          if (_expandedPedidoId == pedido.id) {
                            _expandedPedidoId = null;
                          } else {
                            _expandedPedidoId = pedido.id;
                          }
                        });
                      },
                      onVerPedido: () {
                        _handleVerPedido(pedido);
                      },
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final bool esNuevo;
  final bool expandido;
  final VoidCallback onTap;
  final VoidCallback onVerPedido;

  const _PedidoCard({
    required this.pedido,
    required this.esNuevo,
    required this.expandido,
    required this.onTap,
    required this.onVerPedido,
  });

  String _codigoPedido() {
    final padded = pedido.id.toString().padLeft(4, '0');
    return '#DG-$padded';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (esNuevo) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secundary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Nuevo Pedido Asignado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido ${_codigoPedido()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cliente: ${pedido.nombreUsuario}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Destino: ${pedido.direccionEntrega ?? pedido.ubicacionEntrega}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: Bs ${pedido.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.fastfood, size: 48, color: Colors.orange),
              ],
            ),
            if (expandido) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onVerPedido,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secundary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'VER PEDIDO',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
