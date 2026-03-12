class Pedido {
  final int id;
  final double total;
  final String estado;
  final String ubicacionEntrega;
  final double precioDelivery;
  final String chatId;
  final String nombreUsuario;
  final int? deliveryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? direccionEntrega;

  Pedido({
    required this.id,
    required this.total,
    required this.estado,
    required this.ubicacionEntrega,
    required this.precioDelivery,
    required this.chatId,
    required this.nombreUsuario,
    required this.deliveryId,
    required this.createdAt,
    required this.updatedAt,
    this.direccionEntrega,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'] as int,
      total: (json['total'] as num).toDouble(),
      estado: json['estado'] as String,
      ubicacionEntrega: json['ubicacion_entrega'] as String,
      precioDelivery: (json['precio_delivery'] as num).toDouble(),
      chatId: json['chat_id'] as String,
      nombreUsuario: json['nombre_usuario'] as String,
      deliveryId: json['delivery_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      direccionEntrega: json['direccion_entrega'] as String?,
    );
  }
}
