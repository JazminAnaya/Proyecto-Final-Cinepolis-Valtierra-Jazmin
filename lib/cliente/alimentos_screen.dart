import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/inventario_model.dart';
import 'carrito_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'cliente_home_screen.dart';
import 'mis_compras_screen.dart';
import 'perfil_screen.dart';

class AlimentosScreen extends StatefulWidget {
  final String? clienteId;
  final String? clienteNombre;

  const AlimentosScreen({super.key, this.clienteId, this.clienteNombre});

  @override
  State<AlimentosScreen> createState() => _AlimentosScreenState();
}

class _AlimentosScreenState extends State<AlimentosScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _filtroCategoria = 'Todos';
  bool _isLoading = true;
  List<Inventario> _productos = [];
  final Map<String, int> _carrito = {};

  final List<String> _categorias = ['Todos', 'Alimentos', 'Bebidas', 'Dulces'];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    _cargarCarrito();
  }

  Future<void> _cargarCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> carrito = prefs.getStringList('carrito') ?? [];
    for (var item in carrito) {
      final data = jsonDecode(item);
      if (data['tipo'] == 'alimento') {
        setState(() {
          _carrito[data['id']] = data['cantidad'];
        });
      }
    }
  }

  Future<void> _cargarProductos() async {
    setState(() => _isLoading = true);
    _firebaseService.getInventario().listen((productos) {
      if (mounted) {
        setState(() {
          _productos = productos.where((p) => p.estado == 'Disponible').toList();
          _isLoading = false;
        });
      }
    });
  }

  void _agregarAlCarrito(Inventario producto) {
    setState(() {
      _carrito[producto.id!] = (_carrito[producto.id!] ?? 0) + 1;
    });
    _guardarCarrito();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto.nombre} agregado'), 
        backgroundColor: Colors.green, 
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _quitarDelCarrito(Inventario producto) {
    setState(() {
      if (_carrito[producto.id!] == 1) {
        _carrito.remove(producto.id);
      } else {
        _carrito[producto.id!] = _carrito[producto.id!]! - 1;
      }
    });
    _guardarCarrito();
  }

  Future<void> _guardarCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> carritoExistente = prefs.getStringList('carrito') ?? [];
    List<String> nuevoCarrito = carritoExistente.where((item) {
      final data = jsonDecode(item);
      return data['tipo'] != 'alimento';
    }).toList();
    
    for (var entry in _carrito.entries) {
      final producto = _productos.firstWhere((p) => p.id == entry.key);
      final alimentoItem = {
        'tipo': 'alimento',
        'id': entry.key,
        'nombre': producto.nombre,
        'categoria': producto.categoria,
        'precio': producto.precio,
        'cantidad': entry.value,
        'total': producto.precio * entry.value,
        'imagen': producto.imagen,
      };
      nuevoCarrito.add(jsonEncode(alimentoItem));
    }
    await prefs.setStringList('carrito', nuevoCarrito);
  }

  int get _totalProductosEnCarrito => _carrito.values.fold(0, (sum, qty) => sum + qty);

  IconData _getCategoriaIcon(String categoria) {
    switch (categoria) {
      case 'Alimentos': return Icons.fastfood;
      case 'Bebidas': return Icons.local_drink;
      case 'Dulces': return Icons.cake;
      default: return Icons.inventory;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CarritoScreen(
                    clienteId: widget.clienteId, 
                    clienteNombre: widget.clienteNombre,
                  )));
                },
              ),
              if (_totalProductosEnCarrito > 0)
                Positioned(
                  right: 4, 
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2), 
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)), 
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('$_totalProductosEnCarrito', 
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Alimentos y Bebidas', 
              style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categorias.map((cat) {
                  final isSelected = _filtroCategoria == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat, 
                        style: TextStyle(fontSize: 13, color: isSelected ? const Color(0xFF0D47A1) : Colors.grey),
                      ),
                      selected: isSelected,
                      onSelected: (selected) => setState(() => _filtroCategoria = cat),
                      selectedColor: const Color(0xFF0D47A1).withValues(alpha: 0.2),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildProductosList(crossAxisCount),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Cartelera'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Alimentos'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Mis compras'),
        ],
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ClienteHomeScreen(
              clienteId: widget.clienteId, 
              clienteNombre: widget.clienteNombre,
            )));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CarritoScreen(
              clienteId: widget.clienteId, 
              clienteNombre: widget.clienteNombre,
            )));
          } else if (index == 3) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MisComprasScreen(
              clienteId: widget.clienteId, 
              clienteNombre: widget.clienteNombre,
            )));
          }
        },
      ),
    );
  }

  Widget _buildProductosList(int crossAxisCount) {
    var productosFiltrados = _productos;
    if (_filtroCategoria != 'Todos') {
      productosFiltrados = productosFiltrados.where((p) => p.categoria == _filtroCategoria).toList();
    }
    
    if (productosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(Icons.fastfood, size: 64, color: Colors.grey[400]), 
            const SizedBox(height: 16), 
            Text('No hay productos disponibles', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }
    
    Map<String, List<Inventario>> productosPorCategoria = {};
    for (var p in productosFiltrados) {
      productosPorCategoria.putIfAbsent(p.categoria, () => []).add(p);
    }
    
    return ListView(
      padding: const EdgeInsets.all(12),
      children: productosPorCategoria.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(_getCategoriaIcon(entry.key), color: const Color(0xFF0D47A1), size: 20), 
                  const SizedBox(width: 8), 
                  Text(entry.key, 
                    style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1)),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.55,
              ),
              itemCount: entry.value.length,
              itemBuilder: (context, idx) {
                final producto = entry.value[idx];
                final cantidad = _carrito[producto.id] ?? 0;
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                          child: producto.imagen.isNotEmpty
                              ? Image.network(
                                  producto.imagen, 
                                  fit: BoxFit.cover, 
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFF0D47A1).withValues(alpha: 0.1), 
                                    child: Icon(_getCategoriaIcon(producto.categoria), size: 35, color: const Color(0xFF0D47A1)),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFF0D47A1).withValues(alpha: 0.1), 
                                  child: Icon(_getCategoriaIcon(producto.categoria), size: 35, color: const Color(0xFF0D47A1)),
                                ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                producto.nombre, 
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), 
                                maxLines: 2, 
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '\$${producto.precio.toStringAsFixed(2)}', 
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0D47A1)),
                                  ),
                                  cantidad > 0
                                      ? Container(
                                          height: 34,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: const Color(0xFF0D47A1), width: 1.5),
                                            borderRadius: BorderRadius.circular(17),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove, size: 16), 
                                                onPressed: () => _quitarDelCarrito(producto), 
                                                padding: EdgeInsets.zero, 
                                                constraints: const BoxConstraints(minWidth: 30),
                                                color: const Color(0xFF0D47A1),
                                              ),
                                              Text('$cantidad', 
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D47A1)),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add, size: 16), 
                                                onPressed: () => _agregarAlCarrito(producto), 
                                                padding: EdgeInsets.zero, 
                                                constraints: const BoxConstraints(minWidth: 30),
                                                color: const Color(0xFF0D47A1),
                                              ),
                                            ],
                                          ),
                                        )
                                      : SizedBox(
                                          height: 34,
                                          child: ElevatedButton(
                                            onPressed: () => _agregarAlCarrito(producto), 
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF0D47A1), 
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                                            ), 
                                            child: const Text(
                                              'Agregar',
                                              style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }
}