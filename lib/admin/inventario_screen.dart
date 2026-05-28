import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/inventario_model.dart';
import 'inventario_form_screen.dart';
import 'inventario_detail_screen.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filtroCategoria = 'Todos';
  bool _isLoading = true;
  List<Inventario> _inventarioCache = [];

  final List<String> _categorias = ['Todos', 'Alimentos', 'Bebidas', 'Dulces'];

  IconData _getCategoriaIcon(String categoria) {
    switch (categoria) {
      case 'Alimentos': return Icons.fastfood;
      case 'Bebidas': return Icons.local_drink;
      case 'Dulces': return Icons.cake;
      default: return Icons.inventory;
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarInventario();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarInventario() async {
    setState(() => _isLoading = true);
    _firebaseService.getInventario().listen((productos) {
      if (mounted) {
        setState(() {
        _inventarioCache = productos;
        _isLoading = false;
      });
      }
    });
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: color),
    );
  }

  Future<void> _eliminarProducto(Inventario producto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Deseas eliminar "${producto.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      final success = await _firebaseService.deleteInventario(producto.id!);
      if (success) {
        _mostrarMensaje('Producto eliminado', Colors.green);
        _cargarInventario();
      } else {
        _mostrarMensaje('Error al eliminar', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Inventario', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _cargarInventario)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0D47A1)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categorias.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: _filtroCategoria == cat,
                    onSelected: (selected) => setState(() => _filtroCategoria = cat),
                    selectedColor: const Color(0xFF0D47A1).withValues(alpha: 0.2),
                  ),
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const InventarioFormScreen()));
                  if (result == true) _cargarInventario();
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nuevo Producto', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildCards(),
          ),
        ],
      ),
    );
  }

  Widget _buildCards() {
    var filtrados = _inventarioCache;
    if (_searchQuery.isNotEmpty) {
      filtrados = filtrados.where((p) => p.nombre.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_filtroCategoria != 'Todos') {
      filtrados = filtrados.where((p) => p.categoria == _filtroCategoria).toList();
    }
    if (filtrados.isEmpty) {
      return const Center(child: Text('No hay productos registrados'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtrados.length,
      itemBuilder: (context, index) {
        final producto = filtrados[index];
        Color stockColor = producto.stockDisponible < 10 ? Colors.red : Colors.green;
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Imagen del producto
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: producto.imagen.isNotEmpty
                          ? Image.network(
                              producto.imagen,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(_getCategoriaIcon(producto.categoria), size: 30, color: const Color(0xFF0D47A1)),
                                );
                              },
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(_getCategoriaIcon(producto.categoria), size: 30, color: const Color(0xFF0D47A1)),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${producto.id}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(producto.nombre, style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1)), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('Categoría: ${producto.categoria}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.attach_money, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('\$${producto.precio.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 12),
                              const Icon(Icons.store, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('Stock: ${producto.stockDisponible}', style: TextStyle(fontSize: 14, color: stockColor, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InventarioDetailScreen(producto: producto))),
                      icon: const Icon(Icons.visibility, color: Color(0xFF1976D2), size: 20),
                      label: const Text('Ver', style: TextStyle(color: Color(0xFF1976D2))),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey.shade300),
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => InventarioFormScreen(producto: producto)));
                        if (result == true) _cargarInventario();
                      },
                      icon: const Icon(Icons.edit, color: Color(0xFFFFC107), size: 20),
                      label: const Text('Editar', style: TextStyle(color: Color(0xFFFFC107))),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey.shade300),
                    TextButton.icon(
                      onPressed: () => _eliminarProducto(producto),
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}