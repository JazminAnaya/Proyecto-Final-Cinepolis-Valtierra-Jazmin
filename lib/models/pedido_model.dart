import 'package:cloud_firestore/cloud_firestore.dart';

class Pedido {
  String? id;
  String clienteId;
  String clienteNombre;
  List<Map<String, dynamic>> boletos; // Lista de boletos comprados
  List<Map<String, dynamic>> alimentos; // Lista de alimentos comprados
  double total;
  String metodoPago;
  Map<String, dynamic>? datosTarjeta; // Solo si paga con tarjeta
  DateTime fecha;
  String estado; // 'pendiente', 'pagado', 'cancelado'

  Pedido({
    this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.boletos,
    required this.alimentos,
    required this.total,
    required this.metodoPago,
    this.datosTarjeta,
    required this.fecha,
    this.estado = 'pendiente',
  });

  // Convertir de Firestore a objeto
  factory Pedido.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Pedido(
      id: documentId,
      clienteId: data['clienteId'] ?? '',
      clienteNombre: data['clienteNombre'] ?? '',
      boletos: List<Map<String, dynamic>>.from(data['boletos'] ?? []),
      alimentos: List<Map<String, dynamic>>.from(data['alimentos'] ?? []),
      total: (data['total'] ?? 0).toDouble(),
      metodoPago: data['metodoPago'] ?? '',
      datosTarjeta: data['datosTarjeta'],
      fecha: (data['fecha'] as Timestamp).toDate(),
      estado: data['estado'] ?? 'pendiente',
    );
  }

  // Convertir a mapa para Firestore
  Map<String, dynamic> toMap() {

  return {

    'clienteId': clienteId,
    'clienteNombre': clienteNombre,

    'boletos': boletos,
    'alimentos': alimentos,

    'total': total,
    'metodoPago': metodoPago,

    'fecha': Timestamp.fromDate(fecha),

    'estado': estado,

    'datosTarjeta': datosTarjeta,
  };
}
}

// Modelo para datos de tarjeta (se guarda encriptado en producción)
class DatosTarjeta {
  String titular;
  String numero;
  String fechaVencimiento;
  String cvv;

  DatosTarjeta({
    required this.titular,
    required this.numero,
    required this.fechaVencimiento,
    required this.cvv,
  });

  Map<String, dynamic> toMap() {
    // NOTA: En producción, estos datos deben ir encriptados
    // Solo mostrar los últimos 4 dígitos para seguridad
    return {
      'titular': titular,
      'numeroOculto': '**** **** **** ${numero.substring(numero.length - 4)}',
      'fechaVencimiento': fechaVencimiento,
      'cvv': '***', // No guardar CVV real en producción
    };
  }
}