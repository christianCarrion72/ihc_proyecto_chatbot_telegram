class Detalle {
  final int id;
  final int cantidad;
  final String observacion;
  final int pedidoId;
  final int platoId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Detalle({
    required this.id,
    required this.cantidad,
    required this.observacion,
    required this.pedidoId,
    required this.platoId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Detalle.fromJson(Map<String, dynamic> json) {
    return Detalle(
      id: json['id'] as int,
      cantidad: json['cantidad'] as int,
      observacion: json['observacion'] as String,
      pedidoId: json['pedido_id'] as int,
      platoId: json['plato_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

