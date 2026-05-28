import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:myapp/cliente/cliente_home_screen.dart';
import 'package:myapp/cliente/alimentos_screen.dart';
import 'package:myapp/cliente/pago_screen.dart';
import 'package:myapp/cliente/mis_compras_screen.dart';
import 'perfil_screen.dart';

class CarritoScreen extends StatefulWidget {
  final String? clienteId;
  final String? clienteNombre;

  const CarritoScreen({super.key, this.clienteId, this.clienteNombre});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
  }

  Future<void> _cargarCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> carrito = prefs.getStringList('carrito') ?? [];
    setState(() {
      _items = carrito.map((item) => jsonDecode(item)).toList();
      _isLoading = false;
    });
  }

  Future<void> _eliminarDelCarrito(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> carrito = prefs.getStringList('carrito') ?? [];
    carrito.removeAt(index);
    await prefs.setStringList('carrito', carrito);
    _cargarCarrito();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado del carrito'), backgroundColor: Colors.red),
    );
  }

  double get _totalGeneral {
    double total = 0;
    for (var item in _items) {
      final totalItem = item['total'];
      if (totalItem != null) {
        total += totalItem.toDouble();
      }
    }
    return total;
  }

  int get _totalItems {
    int total = 0;
    for (var item in _items) {
      final String tipo = item['tipo'] ?? '';
      if (tipo == 'alimento') {
        final int cantidad = item['cantidad'] is int 
            ? item['cantidad'] 
            : (item['cantidad'] ?? 0);
        total += cantidad;
      } else if (tipo == 'boletos') {
        total += 1;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), 
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                'https://raw.githubusercontent.com/JazminAnaya/Imagenes-de-Figma-Cinepolis-Valtierra/refs/heads/main/Logo.png', 
                width: 35, 
                height: 35,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 35, 
                  height: 35, 
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), 
                  child: const Icon(Icons.local_movies, color: Color(0xFF0D47A1), size: 20),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¡Bienvenid@!', style: GoogleFonts.roboto(fontSize: 12, color: Colors.white70)),
                  Text(widget.clienteNombre ?? 'Cliente', 
                    style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white), 
                onPressed: () {
                  _cargarCarrito();
                },
              ),
              if (_totalItems > 0)
                Positioned(
                  right: 4, 
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2), 
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)), 
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('$_totalItems', 
                      style: const TextStyle(color: Colors.white, fontSize: 10), 
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Botón de perfil
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerfilScreen(
          clienteId: widget.clienteId,
          clienteNombre: widget.clienteNombre ?? 'Cliente',
        ),
      ),
    );
  },
  child: Container(
    margin: const EdgeInsets.only(right: 16),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Image.network(
        'https://raw.githubusercontent.com/JazminAnaya/Imagenes-de-Figma-Cinepolis-Valtierra/refs/heads/main/perfil.jpeg',
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(Icons.person, color: Color(0xFF0D47A1), size: 25),
          );
        },
      ),
    ),
  ),
),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Carrito vacío', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Agrega boletos o alimentos', style: TextStyle(color: Colors.grey[500])),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClienteHomeScreen(
                                clienteId: widget.clienteId,
                                clienteNombre: widget.clienteNombre,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Ir a la cartelera', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final String tipo = item['tipo'] ?? '';
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      tipo == 'boletos' ? Icons.confirmation_number : Icons.fastfood, 
                                      size: 30, 
                                      color: const Color(0xFF0D47A1),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (tipo == 'boletos') ...[
                                          Text(item['peliculaNombre'] ?? '', 
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('${item['salaNombre']} - ${item['horario']}', 
                                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('Asientos: ${(item['asientos'] as List).join(", ")}', 
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(height: 8),
                                          Text('Cantidad de boletos: ${item['cantidadBoletos'] ?? 0}', 
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                          ),
                                        ] else ...[
                                          Text(item['nombre'] ?? '', 
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('Categoría: ${item['categoria'] ?? ''}', 
                                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('Cantidad: ${item['cantidad'] ?? 0}', 
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                          Text('\$${item['precio'] ?? 0} c/u', 
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Text('Total: \$${item['total'] ?? 0}', 
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1), fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _eliminarDelCarrito(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1), 
                            blurRadius: 10, 
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                            children: [
                              const Text('Total General:', 
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text('\$${_totalGeneral.toStringAsFixed(2)}', 
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ClienteHomeScreen(
                                          clienteId: widget.clienteId,
                                          clienteNombre: widget.clienteNombre,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade300,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Seguir agregando', 
                                    style: TextStyle(color: Color(0xFF0D47A1), fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_items.isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PagoScreen(
                                            clienteId: widget.clienteId,
                                            clienteNombre: widget.clienteNombre,
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('No hay productos en el carrito'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D47A1),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Ir a pagar', 
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Cartelera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Alimentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Mis compras',
          ),
        ],
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ClienteHomeScreen(
                  clienteId: widget.clienteId,
                  clienteNombre: widget.clienteNombre,
                ),
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AlimentosScreen(
                  clienteId: widget.clienteId,
                  clienteNombre: widget.clienteNombre,
                ),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MisComprasScreen(
                  clienteId: widget.clienteId,
                  clienteNombre: widget.clienteNombre,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}