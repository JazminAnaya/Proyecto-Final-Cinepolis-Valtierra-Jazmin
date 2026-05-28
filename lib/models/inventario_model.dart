import 'package:flutter/material.dart';

class Inventario {
  String? id;
  String nombre;
  String categoria;
  double precio;
  int stockDisponible;
  String estado;
  String imagen; // Cambiado de imagenUrl a imagen

  Inventario({
    this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.stockDisponible,
    required this.estado,
    this.imagen = '',
  });

  // Convertir de Firestore a objeto
  factory Inventario.fromFirestore(Map<String, dynamic> data, String documentId) {
    String estado = data['estado']?.toString() ?? 'Disponible';
    if (estado == 'Poco Stock') estado = 'Poco Stock';
    
    return Inventario(
      id: documentId,
      nombre: data['nombre']?.toString() ?? '',
      categoria: data['categoria']?.toString() ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      stockDisponible: (data['stock_disponible'] ?? 0).toInt(),
      estado: estado,
      imagen: data['imagen']?.toString() ?? '', // Campo 'imagen' en Firebase
    );
  }

  // Convertir a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'categoria': categoria,
      'precio': precio,
      'stock_disponible': stockDisponible,
      'estado': estado,
      'imagen': imagen, // Guardar como 'imagen'
    };
  }

  // Copiar con cambios
  Inventario copyWith({
    String? id,
    String? nombre,
    String? categoria,
    double? precio,
    int? stockDisponible,
    String? estado,
    String? imagen,
  }) {
    return Inventario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      precio: precio ?? this.precio,
      stockDisponible: stockDisponible ?? this.stockDisponible,
      estado: estado ?? this.estado,
      imagen: imagen ?? this.imagen,
    );
  }
}

// Función para obtener el color del estado
Color getInventarioEstadoColor(String estado) {
  switch (estado) {
    case 'Disponible':
      return Colors.green;
    case 'Poco Stock':
      return Colors.orange;
    case 'Agotado':
      return Colors.red;
    case 'Descontinuado':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}