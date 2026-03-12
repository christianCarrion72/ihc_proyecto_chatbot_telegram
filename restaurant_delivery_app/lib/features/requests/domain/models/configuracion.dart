class Configuracion {
  final String ubicacionRestaurante;

  Configuracion({
    required this.ubicacionRestaurante,
  });

  factory Configuracion.fromJson(Map<String, dynamic> json) {
    return Configuracion(
      ubicacionRestaurante: json['ubicacion_restaurante'] as String,
    );
  }
}

