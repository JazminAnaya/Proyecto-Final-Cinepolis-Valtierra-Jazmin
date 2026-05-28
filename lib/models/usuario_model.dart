import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  String? id;
  String nombre;
  String email;
  String? telefono;
  int puntosCinepolis;
  String? ciudad;
  String? pais;
  String? fechaNacimiento;
  bool haSeleccionadoSucursales;
  List<String>? sucursalesPreferidas;
  List<String>? sucursalesPreferidasNombres;
  String rol;
  DateTime? fechaRegistro;

  Usuario({
    this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    required this.puntosCinepolis,
    this.ciudad,
    this.pais,
    this.fechaNacimiento,
    this.haSeleccionadoSucursales = false,
    this.sucursalesPreferidas,
    this.sucursalesPreferidasNombres,
    this.rol = 'cliente',
    this.fechaRegistro,
  });

  // Convertir de Firestore a objeto - CORREGIDO
  factory Usuario.fromFirestore(Map<String, dynamic> data, String documentId) {
    // Manejar puntos_cinepolis que puede ser null
    int puntos = 0;
    if (data['puntos_cinepolis'] != null) {
      if (data['puntos_cinepolis'] is int) {
        puntos = data['puntos_cinepolis'];
      } else if (data['puntos_cinepolis'] is String) {
        puntos = int.tryParse(data['puntos_cinepolis']) ?? 0;
      } else if (data['puntos_cinepolis'] is double) {
        puntos = (data['puntos_cinepolis'] as double).toInt();
      }
    }
    
    // Manejar fecha_registro
    DateTime? fechaRegistro;
    if (data['fecha_registro'] != null) {
      if (data['fecha_registro'] is Timestamp) {
        fechaRegistro = (data['fecha_registro'] as Timestamp).toDate();
      }
    }
    
    // Manejar sucursales_preferidas
    List<String>? sucursalesIds;
    if (data['sucursales_preferidas'] != null && data['sucursales_preferidas'] is List) {
      sucursalesIds = List<String>.from(data['sucursales_preferidas'].map((e) => e.toString()));
    }
    
    // Manejar sucursales_preferidas_nombres
    List<String>? sucursalesNombres;
    if (data['sucursales_preferidas_nombres'] != null && data['sucursales_preferidas_nombres'] is List) {
      sucursalesNombres = List<String>.from(data['sucursales_preferidas_nombres'].map((e) => e.toString()));
    }
    
    return Usuario(
      id: documentId,
      nombre: data['nombre']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      telefono: data['telefono']?.toString(),
      puntosCinepolis: puntos,
      ciudad: data['ciudad']?.toString(),
      pais: data['pais']?.toString(),
      fechaNacimiento: data['fecha_nacimiento']?.toString(),
      haSeleccionadoSucursales: data['ha_seleccionado_sucursales'] ?? false,
      sucursalesPreferidas: sucursalesIds,
      sucursalesPreferidasNombres: sucursalesNombres,
      rol: data['rol']?.toString() ?? 'cliente',
      fechaRegistro: fechaRegistro,
    );
  }

  // Convertir a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      if (telefono != null && telefono!.isNotEmpty) 'telefono': telefono,
      'puntos_cinepolis': puntosCinepolis,
      if (ciudad != null && ciudad!.isNotEmpty) 'ciudad': ciudad,
      if (pais != null && pais!.isNotEmpty) 'pais': pais,
      if (fechaNacimiento != null && fechaNacimiento!.isNotEmpty) 'fecha_nacimiento': fechaNacimiento,
      'ha_seleccionado_sucursales': haSeleccionadoSucursales,
      if (sucursalesPreferidas != null && sucursalesPreferidas!.isNotEmpty) 'sucursales_preferidas': sucursalesPreferidas,
      if (sucursalesPreferidasNombres != null && sucursalesPreferidasNombres!.isNotEmpty) 'sucursales_preferidas_nombres': sucursalesPreferidasNombres,
      'rol': rol,
      if (fechaRegistro != null) 'fecha_registro': Timestamp.fromDate(fechaRegistro!),
    };
  }
}