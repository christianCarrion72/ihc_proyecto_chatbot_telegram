import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../domain/models/pedido.dart';
import '../../services/pedido_service.dart';
import 'cancelar_pedido_page.dart';

class EntregaCompletaPage extends StatefulWidget {
  final Pedido pedido;
  final void Function(int) onChangeTab;

  const EntregaCompletaPage({
    super.key,
    required this.pedido,
    required this.onChangeTab,
  });

  @override
  State<EntregaCompletaPage> createState() => _EntregaCompletaPageState();
}

class _EntregaCompletaPageState extends State<EntregaCompletaPage> {
  final PedidoService _pedidoService = PedidoService();
  bool _completando = false;

  String _codigoPedido() {
    final padded = widget.pedido.id.toString().padLeft(4, '0');
    return '#DG-$padded';
  }

  Future<void> _completarEntrega() async {
    if (_completando) return;
    setState(() {
      _completando = true;
    });
    try {
      await _pedidoService.actualizarEstado(widget.pedido.id, 'entregado');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido entregado exitosamente')),
      );
      widget.onChangeTab(0);
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _completando = false;
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
                          'ENTREGA COMPLETA?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pedido ${_codigoPedido()} a ${widget.pedido.nombreUsuario}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.success,
                              width: 12,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check,
                              size: 56,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: _SlideToCompleteButton(
                            onComplete: _completarEntrega,
                            enabled: !_completando,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
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
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: const Text(
                              'Reportar Problema',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
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

class _SlideToCompleteButton extends StatefulWidget {
  final VoidCallback onComplete;
  final bool enabled;

  const _SlideToCompleteButton({
    required this.onComplete,
    required this.enabled,
  });

  @override
  State<_SlideToCompleteButton> createState() => _SlideToCompleteButtonState();
}

class _SlideToCompleteButtonState extends State<_SlideToCompleteButton> {
  double _dragPercent = 0.0;
  bool _completed = false;

  void _handleDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (!widget.enabled || _completed) return;
    final delta = details.primaryDelta ?? 0;
    const thumbSize = 56.0;
    final availableWidth = maxWidth - thumbSize;
    if (availableWidth <= 0) return;
    final currentPosition = _dragPercent * availableWidth;
    final newPosition = (currentPosition + delta).clamp(0.0, availableWidth);
    setState(() {
      _dragPercent = newPosition / availableWidth;
    });
  }

  void _handleDragEnd(double maxWidth) {
    if (!widget.enabled || _completed) return;
    if (_dragPercent > 0.8) {
      setState(() {
        _dragPercent = 1.0;
        _completed = true;
      });
      widget.onComplete();
    } else {
      setState(() {
        _dragPercent = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        const thumbSize = 56.0;
        final availableWidth = (maxWidth - thumbSize).clamp(0.0, maxWidth);
        final thumbOffset = availableWidth <= 0
            ? 0.0
            : _dragPercent * availableWidth;

        return GestureDetector(
          onHorizontalDragUpdate: (details) =>
              _handleDragUpdate(details, maxWidth),
          onHorizontalDragEnd: (_) => _handleDragEnd(maxWidth),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: widget.enabled
                  ? AppColors.secundary.withOpacity(0.12)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Center(
                  child: Text(
                    _completed ? 'Completado' : 'Desliza para completar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.enabled
                          ? AppColors.secundary
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                Positioned(
                  left: thumbOffset,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: widget.enabled
                          ? AppColors.secundary
                          : Colors.grey.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
