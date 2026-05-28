import 'package:cloud_firestore/cloud_firestore.dart';

class Sala {
  String? id;
  String nombre;
  int capacidad;
  String tipo;
  String idComplejo;
  String nombreComplejo;

  Sala({
    this.id,
    required this.nombre,
    required this.capacidad,
    required this.tipo,
    required this.idComplejo,
    this.nombreComplejo = '',
  });

  // Convertir de Firestore a objeto
  factory Sala.fromFirestore(Map<String, dynamic> data, String documentId) {
    // Manejar id_complejos que puede ser String o DocumentReference
    String complejoId = '';
    if (data['id_complejos'] != null) {
      if (data['id_complejos'] is String) {
        complejoId = data['id_complejos'] as String;
      } else if (data['id_complejos'] is DocumentReference) {
        complejoId = (data['id_complejos'] as DocumentReference).id;
      }
    }

    return Sala(
      id: documentId,
      nombre: data['nombre']?.toString() ?? '',
      capacidad: (data['capacidad'] ?? 0).toInt(),
      tipo: data['tipo']?.toString() ?? '',
      idComplejo: complejoId,
      nombreComplejo: data['nombre_complejo']?.toString() ?? '',
    );
  }

  // Convertir a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'capacidad': capacidad,
      'tipo': tipo,
      'id_complejos': idComplejo,
    };
  }

  // Copiar con cambios
  Sala copyWith({
    String? id,
    String? nombre,
    int? capacidad,
    String? tipo,
    String? idComplejo,
    String? nombreComplejo,
  }) {
    return Sala(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      capacidad: capacidad ?? this.capacidad,
      tipo: tipo ?? this.tipo,
      idComplejo: idComplejo ?? this.idComplejo,
      nombreComplejo: nombreComplejo ?? this.nombreComplejo,
    );
  }
}