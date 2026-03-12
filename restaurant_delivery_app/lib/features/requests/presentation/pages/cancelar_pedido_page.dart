import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../domain/models/pedido.dart';
import '../../services/pedido_service.dart';

class CancelarPedidoPage extends StatefulWidget {
  final Pedido pedido;
  final void Function(int) onChangeTab;

  const CancelarPedidoPage({
    super.key,
    required this.pedido,
    required this.onChangeTab,
  });

  @override
  State<CancelarPedidoPage> createState() => _CancelarPedidoPageState();
}

class _CancelarPedidoPageState extends State<CancelarPedidoPage> {
  final PedidoService _pedidoService = PedidoService();
  String? _motivoSeleccionado;
  bool _cancelando = false;

  String _codigoPedido() {
    final padded = widget.pedido.id.toString().padLeft(4, '0');
    return '#DG-$padded';
  }

  Future<void> _confirmarCancelacion() async {
    if (_motivoSeleccionado == null || _motivoSeleccionado!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un motivo')),
      );
      return;
    }

    if (_cancelando) return;

    setState(() {
      _cancelando = true;
    });

    try {
      await _pedidoService.cancelar(widget.pedido.id, _motivoSeleccionado!);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El pedido fue cancelado')));

      widget.onChangeTab(0);
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _cancelando = false;
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
              const AppHeader(),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'CANCELAR PEDIDO?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pedido ${_codigoPedido()} a ${widget.pedido.nombreUsuario}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.red, width: 12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.close,
                              size: 56,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _MotivoChip(
                              texto: 'Cliente no responde',
                              seleccionado:
                                  _motivoSeleccionado == 'Cliente no responde',
                              onTap: () {
                                setState(() {
                                  _motivoSeleccionado = 'Cliente no responde';
                                });
                              },
                            ),
                            _MotivoChip(
                              texto: 'Problemas con el vehículo',
                              seleccionado:
                                  _motivoSeleccionado ==
                                  'Problemas con el vehículo',
                              onTap: () {
                                setState(() {
                                  _motivoSeleccionado =
                                      'Problemas con el vehículo';
                                });
                              },
                            ),
                            _MotivoChip(
                              texto: 'Restaurante cerrado',
                              seleccionado:
                                  _motivoSeleccionado == 'Restaurante cerrado',
                              onTap: () {
                                setState(() {
                                  _motivoSeleccionado = 'Restaurante cerrado';
                                });
                              },
                            ),
                          ],
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _cancelando
                                ? null
                                : _confirmarCancelacion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: const Text(
                              'Reportar Problema',
                              style: TextStyle(
                                fontSize: 14,
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

class _MotivoChip extends StatelessWidget {
  final String texto;
  final bool seleccionado;
  final VoidCallback onTap;

  const _MotivoChip({
    required this.texto,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.secundary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: seleccionado ? AppColors.secundary : Colors.black12,
          ),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: seleccionado ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
