import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/pelicula_model.dart';
import 'peliculas_form_screen.dart';
import 'peliculas_detail_screen.dart';

class PeliculasScreen extends StatefulWidget {
  const PeliculasScreen({super.key});

  @override
  State<PeliculasScreen> createState() => _PeliculasScreenState();
}

class _PeliculasScreenState extends State<PeliculasScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filtroGenero = 'Todos';
  bool _isLoading = true;
  List<Pelicula> _peliculasCache = [];

  final List<String> _generos = ['Todos', 'Acción', 'Aventura', 'Ciencia Ficción', 'Comedia', 'Drama', 'Terror', 'Romance', 'Animación'];

  @override
  void initState() {
    super.initState();
    _cargarPeliculas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarPeliculas() async {
    setState(() => _isLoading = true);
    _firebaseService.getPeliculas().listen((peliculas) {
      if (mounted) {
        setState(() {
        _peliculasCache = peliculas;
        _isLoading = false;
      });
      }
    });
  }

  Future<void> _eliminarPelicula(Pelicula pelicula) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Película'),
        content: Text('¿Deseas eliminar "${pelicula.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      final success = await _firebaseService.deletePelicula(pelicula.id!);
      if (success) _cargarPeliculas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Películas', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _cargarPeliculas)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar película...',
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
                children: _generos.map((genero) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(genero),
                    selected: _filtroGenero == genero,
                    onSelected: (selected) => setState(() => _filtroGenero = genero),
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
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const PeliculasFormScreen()));
                  if (result == true) _cargarPeliculas();
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nueva Película', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
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
    var filtrados = _peliculasCache;
    if (_searchQuery.isNotEmpty) {
      filtrados = filtrados.where((p) => p.nombre.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_filtroGenero != 'Todos') {
      filtrados = filtrados.where((p) => p.genero == _filtroGenero).toList();
    }
    if (filtrados.isEmpty) {
      return const Center(child: Text('No hay películas registradas'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtrados.length,
      itemBuilder: (context, index) {
        final pelicula = filtrados[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contenido de la tarjeta con imagen más pequeña a la izquierda
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen pequeña (60x80)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: pelicula.imagen != null && pelicula.imagen!.isNotEmpty
                          ? Image.network(
                              pelicula.imagen!,
                              width: 60,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 80,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image, size: 30, color: Colors.grey),
                                );
                              },
                            )
                          : Container(
                              width: 60,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.movie, size: 30, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(width: 12),
                    // Información de la película
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${pelicula.id}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            pelicula.nombre,
                            style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text('Género: ${pelicula.genero}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                          Text('Duración: ${pelicula.duracionMin} min', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              pelicula.clasificacion,
                              style: const TextStyle(fontSize: 10, color: Colors.purple, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Botones en la parte inferior
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PeliculasDetailScreen(pelicula: pelicula))),
                      icon: const Icon(Icons.visibility, color: Color(0xFF1976D2), size: 20),
                      label: const Text('Ver', style: TextStyle(color: Color(0xFF1976D2))),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey.shade300),
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => PeliculasFormScreen(pelicula: pelicula)));
                        if (result == true) _cargarPeliculas();
                      },
                      icon: const Icon(Icons.edit, color: Color(0xFFFFC107), size: 20),
                      label: const Text('Editar', style: TextStyle(color: Color(0xFFFFC107))),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey.shade300),
                    TextButton.icon(
                      onPressed: () => _eliminarPelicula(pelicula),
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