class Delivery {
  final int id;
  final String nombre;
  final String email;
  final String ubicacion;
  final bool disponible;

  Delivery({
    required this.id,
    required this.nombre,
    required this.email,
    required this.ubicacion,
    required this.disponible,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      ubicacion: json['ubicacion'] as String,
      disponible: json['disponible'] as bool,
    );
  }
}

