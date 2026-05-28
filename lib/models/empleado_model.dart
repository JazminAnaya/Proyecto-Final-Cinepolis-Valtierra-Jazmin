import 'package:cloud_firestore/cloud_firestore.dart';

class Empleado {
  String? id;
  String nombre;
  String email;
  String telefono;
  String rfc;
  String puesto;
  double salario;
  String idComplejo;

  Empleado({
    this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.rfc,
    required this.puesto,
    required this.salario,
    required this.idComplejo,
  });

  // Convertir de Firestore a objeto
  factory Empleado.fromFirestore(Map<String, dynamic> data, String documentId) {
    // Manejar id_complejo que puede ser String o DocumentReference
    String complejoId = '';
    if (data['id_complejo'] != null) {
      if (data['id_complejo'] is String) {
        complejoId = data['id_complejo'] as String;
      } else if (data['id_complejo'] is DocumentReference) {
        complejoId = (data['id_complejo'] as DocumentReference).id;
      }
    }

    return Empleado(
      id: documentId,
      nombre: data['nombre']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      telefono: data['telefono']?.toString() ?? '',
      rfc: data['RFC']?.toString() ?? '',  // ← CAMBIADO: 'RFC' mayúscula
      puesto: data['puesto']?.toString() ?? '',
      salario: (data['salario'] ?? 0).toDouble(),
      idComplejo: complejoId,
    );
  }

  // Convertir a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'RFC': rfc,  // ← CAMBIADO: 'RFC' mayúscula
      'puesto': puesto,
      'salario': salario,
      'id_complejo': idComplejo,
    };
  }

  // Copiar con cambios
  Empleado copyWith({
    String? id,
    String? nombre,
    String? email,
    String? telefono,
    String? rfc,
    String? puesto,
    double? salario,
    String? idComplejo,
  }) {
    return Empleado(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      rfc: rfc ?? this.rfc,
      puesto: puesto ?? this.puesto,
      salario: salario ?? this.salario,
      idComplejo: idComplejo ?? this.idComplejo,
    );
  }
}