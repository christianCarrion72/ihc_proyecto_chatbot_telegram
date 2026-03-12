class Plato {
  final int id;
  final String nombre;
  final double precioVenta;
  final String urlImagen;
  final int categoriaId;

  Plato({
    required this.id,
    required this.nombre,
    required this.precioVenta,
    required this.urlImagen,
    required this.categoriaId,
  });

  factory Plato.fromJson(Map<String, dynamic> json) {
    return Plato(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      precioVenta: (json['precio_venta'] as num).toDouble(),
      urlImagen: json['url_imagen'] as String,
      categoriaId: json['categoria_id'] as int,
    );
  }
}

