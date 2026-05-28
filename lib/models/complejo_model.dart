class Complejo {
  String? id;
  String nombre;
  String ciudad;
  String direccion;
  String telefono;
  String estado;

  Complejo({
    this.id,
    required this.nombre,
    required this.ciudad,
    required this.direccion,
    required this.telefono,
    required this.estado,
  });

  // Convertir de Firestore a objeto
  factory Complejo.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Complejo(
      id: documentId,
      nombre: data['nombre']?.toString() ?? '',
      ciudad: data['ciudad']?.toString() ?? '',
      direccion: data['direccion']?.toString() ?? '',
      telefono: data['telefono']?.toString() ?? '',
      estado: data['estado']?.toString() ?? 'Activo',
    );
  }

  // Convertir a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'ciudad': ciudad,
      'direccion': direccion,
      'telefono': telefono,
      'estado': estado,
    };
  }

  // Copiar con cambios
  Complejo copyWith({
    String? id,
    String? nombre,
    String? ciudad,
    String? direccion,
    String? telefono,
    String? estado,
  }) {
    return Complejo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      ciudad: ciudad ?? this.ciudad,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      estado: estado ?? this.estado,
    );
  }
}