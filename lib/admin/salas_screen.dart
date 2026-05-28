import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/sala_model.dart';
import 'salas_form_screen.dart';
import 'salas_detail_screen.dart';

class SalasScreen extends StatefulWidget {
  const SalasScreen({super.key});

  @override
  State<SalasScreen> createState() => _SalasScreenState();
}

class _SalasScreenState extends State<SalasScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filtroTipo = 'Todos';
  bool _isLoading = true;
  List<Sala> _salasCache = [];

  // Tipos de sala actualizados
  final List<String> _tipos = [
    'Todos',
    'Macro XE',
    'VIP',
    '4DX',
    'ScreenX',
    'IMAX',
    'Sala Normal',
    'Sala 3D',
    'Sala Premium',
    'Sala 4K',
    'Sala DBOX'
  ];

  @override
  void initState() {
    super.initState();
    _cargarSalas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarSalas() async {
    setState(() => _isLoading = true);
    _firebaseService.getSalas().listen((salas) async {
      // Cargar nombres de complejos para cada sala
      for (var sala in salas) {
        if (sala.idComplejo.isNotEmpty && sala.nombreComplejo.isEmpty) {
          final complejo = await _firebaseService.getComplejoById(sala.idComplejo);
          if (complejo != null) {
            sala.nombreComplejo = complejo.nombre;
          }
        }
      }
      if (mounted) {
        setState(() {
        _salasCache = salas;
        _isLoading = false;
      });
      }
    });
  }

  Future<void> _eliminarSala(Sala sala) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Sala'),
        content: Text('¿Deseas eliminar "${sala.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      final success = await _firebaseService.deleteSala(sala.id!);
      if (success) _cargarSalas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Salas', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _cargarSalas)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar sala...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0D47A1)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          // Filtros de tipo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tipos.map((tipo) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(tipo),
                    selected: _filtroTipo == tipo,
                    onSelected: (selected) => setState(() => _filtroTipo = tipo),
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
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SalasFormScreen()));
                  if (result == true) _cargarSalas();
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nuevo Sala', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
    var filtrados = _salasCache;
    if (_searchQuery.isNotEmpty) {
      filtrados = filtrados.where((s) => s.nombre.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_filtroTipo != 'Todos') {
      filtrados = filtrados.where((s) => s.tipo == _filtroTipo).toList();
    }
    if (filtrados.isEmpty) {
      return const Center(child: Text('No hay salas registradas'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtrados.length,
      itemBuilder: (context, index) {
        final sala = filtrados[index];
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
                    Text('ID: ${sala.id}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(sala.nombre, style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1))),
                    const SizedBox(height: 4),
                    Text('Tipo: ${sala.tipo} • Capacidad: ${sala.capacidad}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text('Sucursal: ${sala.nombreComplejo.isNotEmpty ? sala.nombreComplejo : sala.idComplejo}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
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
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SalasDetailScreen(sala: sala))),
                      icon: const Icon(Icons.visibility, color: Color(0xFF1976D2), size: 20),
                      label: const Text('Ver', style: TextStyle(color: Color(0xFF1976D2))),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey.shade300),
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => SalasFormScreen(sala: sala)));
                        if (result == true) _cargarSalas();
                      },
                      icon: const Icon(Icons.edit, color: Color(0xFFFFC107), size: 20),
                      label: const Text('Editar', style: TextStyle(color: Color(0xFFFFC107))),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey.shade300),
                    TextButton.icon(
                      onPressed: () => _eliminarSala(sala),
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