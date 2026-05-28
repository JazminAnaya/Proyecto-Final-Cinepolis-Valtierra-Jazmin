import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/funcion_model.dart';
import 'funciones_form_screen.dart';
import 'funciones_detail_screen.dart';

class FuncionesScreen extends StatefulWidget {
  const FuncionesScreen({super.key});

  @override
  State<FuncionesScreen> createState() => _FuncionesScreenState();
}

class _FuncionesScreenState extends State<FuncionesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filtroEstado = 'Todos';
  bool _isLoading = true;
  List<Funcion> _funcionesCache = [];

  final List<String> _estados = ['Todos', 'Disponible', 'Cancelada', 'Completada'];

  @override
  void initState() {
    super.initState();
    _cargarFunciones();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarFunciones() async {
    setState(() => _isLoading = true);
    _firebaseService.getFunciones().listen((funciones) async {
      // Cargar nombres de películas, salas y complejos
      for (var funcion in funciones) {
        if (funcion.idPelicula.isNotEmpty && funcion.nombrePelicula.isEmpty) {
          final pelicula = await _firebaseService.getPeliculaById(funcion.idPelicula);
          if (pelicula != null) {
            funcion.nombrePelicula = pelicula.nombre;
          }
        }
        if (funcion.idSala.isNotEmpty && funcion.nombreSala.isEmpty) {
          final sala = await _firebaseService.getSalaById(funcion.idSala);
          if (sala != null) {
            funcion.nombreSala = sala.nombre;
          }
        }
        if (funcion.idComplejo.isNotEmpty && funcion.nombreComplejo.isEmpty) {
          final complejo = await _firebaseService.getComplejoById(funcion.idComplejo);
          if (complejo != null) {
            funcion.nombreComplejo = complejo.nombre;
          }
        }
      }
      if (mounted) {
        setState(() {
        _funcionesCache = funciones;
        _isLoading = false;
      });
      }
    });
  }

  Future<void> _eliminarFuncion(Funcion funcion) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Función'),
        content: Text('¿Deseas eliminar la función de "${funcion.nombrePelicula}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      final success = await _firebaseService.deleteFuncion(funcion.id!);
      if (success) _cargarFunciones();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Funciones', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _cargarFunciones)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por película...',
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
                children: _estados.map((estado) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(estado),
                    selected: _filtroEstado == estado,
                    onSelected: (selected) => setState(() => _filtroEstado = estado),
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
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const FuncionesFormScreen()));
                  if (result == true) _cargarFunciones();
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nuevo Funcion', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
    var filtrados = _funcionesCache;
    if (_searchQuery.isNotEmpty) {
      filtrados = filtrados.where((f) => f.nombrePelicula.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_filtroEstado != 'Todos') {
      filtrados = filtrados.where((f) => f.estado == _filtroEstado).toList();
    }
    if (filtrados.isEmpty) {
      return const Center(child: Text('No hay funciones registradas'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtrados.length,
      itemBuilder: (context, index) {
        final funcion = filtrados[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${funcion.id}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(funcion.nombrePelicula.isNotEmpty ? funcion.nombrePelicula : 'Cargando...', 
                        style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1))),
                    const SizedBox(height: 4),
                    Text('Formato: ${funcion.formato} • ${funcion.fechaFormateada}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text('Sucursal: ${funcion.nombreComplejo.isNotEmpty ? funcion.nombreComplejo : funcion.idComplejo}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('Precio: \$${funcion.precioBase.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: getEstadoColor(funcion.estado).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(funcion.estado, style: TextStyle(color: getEstadoColor(funcion.estado), fontSize: 12, fontWeight: FontWeight.w500)),
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
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FuncionesDetailScreen(funcion: funcion))),
                      icon: const Icon(Icons.visibility, color: Color(0xFF1976D2), size: 20),
                      label: const Text('Ver', style: TextStyle(color: Color(0xFF1976D2))),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey.shade300),
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => FuncionesFormScreen(funcion: funcion)));
                        if (result == true) _cargarFunciones();
                      },
                      icon: const Icon(Icons.edit, color: Color(0xFFFFC107), size: 20),
                      label: const Text('Editar', style: TextStyle(color: Color(0xFFFFC107))),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey.shade300),
                    TextButton.icon(
                      onPressed: () => _eliminarFuncion(funcion),
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