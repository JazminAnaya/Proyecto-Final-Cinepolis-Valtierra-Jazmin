// lib/models/carrito_model.dart
class CarritoItem {
  final String tipo;
  final int cantidad;
  final int precio;
  final int subtotal;
  String? nombre;
  String? imagen;

  CarritoItem({
    required this.tipo,
    required this.cantidad,
    required this.precio,
    required this.subtotal,
    this.nombre,
    this.imagen,
  });

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'cantidad': cantidad,
      'precio': precio,
      'subtotal': subtotal,
      'nombre': nombre,
      'imagen': imagen,
    };
  }

  factory CarritoItem.fromMap(Map<String, dynamic> map) {
    return CarritoItem(
      tipo: map['tipo'] ?? '',
      cantidad: map['cantidad'] ?? 0,
      precio: map['precio'] ?? 0,
      subtotal: map['subtotal'] ?? 0,
      nombre: map['nombre'],
      imagen: map['imagen'],
    );
  }
}

class CarritoBoletos {
  final String peliculaNombre;
  final String salaNombre;
  final String horario;
  final List<String> asientos;
  final List<CarritoItem> items;
  final int total;

  CarritoBoletos({
    required this.peliculaNombre,
    required this.salaNombre,
    required this.horario,
    required this.asientos,
    required this.items,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'tipo': 'boletos',
      'peliculaNombre': peliculaNombre,
      'salaNombre': salaNombre,
      'horario': horario,
      'asientos': asientos,
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  factory CarritoBoletos.fromMap(Map<String, dynamic> map) {
    return CarritoBoletos(
      peliculaNombre: map['peliculaNombre'] ?? '',
      salaNombre: map['salaNombre'] ?? '',
      horario: map['horario'] ?? '',
      asientos: List<String>.from(map['asientos'] ?? []),
      items: (map['items'] as List?)?.map((i) => CarritoItem.fromMap(i)).toList() ?? [],
      total: map['total'] ?? 0,
    );
  }
}

class CarritoAlimento {
  final String id;
  final String nombre;
  final String categoria;
  final double precio;
  final int cantidad;
  final String? imagen;

  CarritoAlimento({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.cantidad,
    this.imagen,
  });

  Map<String, dynamic> toMap() {
    return {
      'tipo': 'alimento',
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'precio': precio,
      'cantidad': cantidad,
      'imagen': imagen,
    };
  }

  factory CarritoAlimento.fromMap(Map<String, dynamic> map) {
    return CarritoAlimento(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      categoria: map['categoria'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      cantidad: map['cantidad'] ?? 0,
      imagen: map['imagen'],
    );
  }
}