import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Funcion {
  String? id;
  String estado;
  DateTime fechaHora;
  String formato;
  String idPelicula;
  String nombrePelicula;
  String idSala;
  String nombreSala;
  String idComplejo;
  String nombreComplejo;
  double precioBase;

  Funcion({
    this.id,
    required this.estado,
    required this.fechaHora,
    required this.formato,
    required this.idPelicula,
    this.nombrePelicula = '',
    required this.idSala,
    this.nombreSala = '',
    required this.idComplejo,
    this.nombreComplejo = '',
    required this.precioBase,
  });

  // Convertir de Firestore a objeto
  factory Funcion.fromFirestore(Map<String, dynamic> data, String documentId) {
    // Manejar id_pelicula
    String peliculaId = '';
    if (data['id_pelicula'] != null) {
      if (data['id_pelicula'] is String) {
        peliculaId = data['id_pelicula'] as String;
      } else if (data['id_pelicula'] is DocumentReference) {
        peliculaId = (data['id_pelicula'] as DocumentReference).id;
      }
    }

    // Manejar id_sala
    String salaId = '';
    if (data['id_sala'] != null) {
      if (data['id_sala'] is String) {
        salaId = data['id_sala'] as String;
      } else if (data['id_sala'] is DocumentReference) {
        salaId = (data['id_sala'] as DocumentReference).id;
      }
    }

    // Manejar id_complejo
    String complejoId = '';
    if (data['id_complejo'] != null) {
      if (data['id_complejo'] is String) {
        complejoId = data['id_complejo'] as String;
      } else if (data['id_complejo'] is DocumentReference) {
        complejoId = (data['id_complejo'] as DocumentReference).id;
      }
    }

    // Manejar fecha_hora
    DateTime fechaHora = DateTime.now();
    if (data['fecha_hora'] != null) {
      try {
        if (data['fecha_hora'] is Timestamp) {
          fechaHora = (data['fecha_hora'] as Timestamp).toDate();
        } else if (data['fecha_hora'] is String) {
          fechaHora = DateTime.parse(data['fecha_hora']);
        }
      } catch (e) {
        print('Error al parsear fecha: $e');
      }
    }

    // Manejar formato
    String formato = data['formato']?.toString() ?? '2D';
    if (formato == 'VIP 2D') formato = '2D';
    if (formato == 'VIP 3D') formato = '3D';

    // Manejar estado
    String estado = data['estado']?.toString() ?? 'Disponible';
    if (estado == 'Lleno') estado = 'Disponible';
    if (estado == 'Agotado') estado = 'Cancelada';

    return Funcion(
      id: documentId,
      estado: estado,
      fechaHora: fechaHora,
      formato: formato,
      idPelicula: peliculaId,
      nombrePelicula: data['nombre_pelicula']?.toString() ?? '',
      idSala: salaId,
      nombreSala: data['nombre_sala']?.toString() ?? '',
      idComplejo: complejoId,
      nombreComplejo: data['nombre_complejo']?.toString() ?? '',
      precioBase: (data['precio_base'] ?? 0).toDouble(),
    );
  }

  // Convertir a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'estado': estado,
      'fecha_hora': Timestamp.fromDate(fechaHora),
      'formato': formato,
      'id_pelicula': idPelicula,
      'nombre_pelicula': nombrePelicula,
      'id_sala': idSala,
      'nombre_sala': nombreSala,
      'id_complejo': idComplejo,
      'nombre_complejo': nombreComplejo,
      'precio_base': precioBase,
    };
  }

  // Copiar con cambios
  Funcion copyWith({
    String? id,
    String? estado,
    DateTime? fechaHora,
    String? formato,
    String? idPelicula,
    String? nombrePelicula,
    String? idSala,
    String? nombreSala,
    String? idComplejo,
    String? nombreComplejo,
    double? precioBase,
  }) {
    return Funcion(
      id: id ?? this.id,
      estado: estado ?? this.estado,
      fechaHora: fechaHora ?? this.fechaHora,
      formato: formato ?? this.formato,
      idPelicula: idPelicula ?? this.idPelicula,
      nombrePelicula: nombrePelicula ?? this.nombrePelicula,
      idSala: idSala ?? this.idSala,
      nombreSala: nombreSala ?? this.nombreSala,
      idComplejo: idComplejo ?? this.idComplejo,
      nombreComplejo: nombreComplejo ?? this.nombreComplejo,
      precioBase: precioBase ?? this.precioBase,
    );
  }

  // Formatear fecha para mostrar
  String get fechaFormateada {
    return '${fechaHora.day}/${fechaHora.month}/${fechaHora.year} ${fechaHora.hour}:${fechaHora.minute.toString().padLeft(2, '0')}';
  }
}

// Función para obtener el color según el estado
Color getEstadoColor(String estado) {
  switch (estado) {
    case 'Disponible':
      return Colors.green;
    case 'Cancelada':
      return Colors.red;
    case 'Completada':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}