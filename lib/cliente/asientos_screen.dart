import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'tipo_boletos_screen.dart';
import 'perfil_screen.dart';

class AsientosScreen extends StatefulWidget {
  final String peliculaNombre;
  final String salaId;
  final String horario;
  final String? clienteId;
  final String? clienteNombre;
  final String funcionId;

  const AsientosScreen({
    super.key,
    required this.peliculaNombre,
    required this.salaId,
    required this.horario,
    this.clienteId,
    this.clienteNombre,
    required this.funcionId,
  });

  @override
  State<AsientosScreen> createState() => _AsientosScreenState();
}

class _AsientosScreenState extends State<AsientosScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  
  // TODAS LAS FILAS - Incluyendo A y B
  final List<String> _filas = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'];
  final int _asientosPorFila = 10;
  
  final Map<String, List<int>> _asientosSeleccionados = {};
  
  final Map<String, List<int>> _asientosOcupados = {
    'A': [],  // Fila A vacía
    'B': [],  // Fila B vacía
    'C': [3, 4, 5],
    'D': [7, 8],
    'E': [2],
    'F': [6, 9],
    'G': [4, 5, 6],
    'H': [8],
    'I': [2, 3],
    'J': [5],
    'K': [],
    'L': [9, 10],
  };

  String _nombreSala = 'Cargando...';
  bool _isLoadingSala = true;

  @override
  void initState() {
    super.initState();
    for (var fila in _filas) {
      _asientosSeleccionados[fila] = [];
    }
    _cargarNombreSala();
  }

  Future<void> _cargarNombreSala() async {
    try {
      final sala = await _firebaseService.getSalaById(widget.salaId);
      if (sala != null && mounted) {
        setState(() {
          _nombreSala = sala.nombre;
          _isLoadingSala = false;
        });
      } else {
        setState(() {
          _nombreSala = 'Sala';
          _isLoadingSala = false;
        });
      }
    } catch (e) {
      setState(() {
        _nombreSala = 'Sala';
        _isLoadingSala = false;
      });
    }
  }

  bool _isSelected(String fila, int numero) {
    return _asientosSeleccionados[fila]?.contains(numero) ?? false;
  }

  bool _isOccupied(String fila, int numero) {
    return _asientosOcupados[fila]?.contains(numero) ?? false;
  }

  void _toggleAsiento(String fila, int numero) {
    if (_isOccupied(fila, numero)) return;
    
    setState(() {
      if (_isSelected(fila, numero)) {
        _asientosSeleccionados[fila]?.remove(numero);
      } else {
        _asientosSeleccionados[fila]?.add(numero);
      }
    });
  }

  String get _asientosSeleccionadosTexto {
    List<String> asientos = [];
    for (var entry in _asientosSeleccionados.entries) {
      for (var numero in entry.value) {
        asientos.add('${entry.key}$numero');
      }
    }
    asientos.sort();
    return asientos.join(', ');
  }

  List<String> get _asientosSeleccionadosLista {
    List<String> asientos = [];
    for (var entry in _asientosSeleccionados.entries) {
      for (var numero in entry.value) {
        asientos.add('${entry.key}$numero');
      }
    }
    asientos.sort();
    return asientos;
  }

  int get _totalSeleccionados {
    int total = 0;
    for (var entry in _asientosSeleccionados.entries) {
      total += entry.value.length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Asientos más pequeños
    final asientoSize = screenWidth > 400 ? 26.0 : 22.0;
    final asientoIconSize = screenWidth > 400 ? 12.0 : 10.0;
    final spacing = 2.0;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
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
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.local_movies, color: Color(0xFF0D47A1), size: 20),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¡Bienvenid@!', style: GoogleFonts.roboto(fontSize: 12, color: Colors.white70)),
                  Text(widget.clienteNombre ?? 'Cliente', style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                Text(widget.peliculaNombre, style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1))),
                const SizedBox(height: 2),
                if (_isLoadingSala)
                  const SizedBox(height: 16, width: 16, child: CircularProgressIndicator())
                else
                  Text('$_nombreSala - ${widget.horario}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text('PANTALLA', style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4)),
            ),
          ),
          
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Column(
                    children: _filas.map((fila) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.5),
                        child: Row(
                          children: [
                            Container(
                              width: asientoSize,
                              height: asientoSize,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.1)],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: Center(
                                child: Text(fila, style: TextStyle(fontSize: asientoIconSize + 1, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: List.generate(_asientosPorFila, (index) {
                                int numero = index + 1;
                                bool isSelected = _isSelected(fila, numero);
                                bool isOccupied = _isOccupied(fila, numero);
                                
                                Color asientoColor;
                                Color iconColor;
                                
                                if (isSelected) {
                                  asientoColor = const Color(0xFF0D47A1);
                                  iconColor = Colors.white;
                                } else if (isOccupied) {
                                  asientoColor = Colors.grey.shade600;
                                  iconColor = Colors.white;
                                } else {
                                  asientoColor = Colors.white;
                                  iconColor = const Color(0xFF0D47A1);
                                }
                                
                                return GestureDetector(
                                  onTap: () => _toggleAsiento(fila, numero),
                                  child: Container(
                                    width: asientoSize,
                                    height: asientoSize,
                                    decoration: BoxDecoration(
                                      color: asientoColor,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 1, offset: const Offset(0, 1))],
                                      border: Border.all(color: isSelected ? Colors.white.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3), width: 0.5),
                                    ),
                                    child: Icon(Icons.event_seat, size: asientoIconSize, color: iconColor),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(Colors.grey.shade300, 'Libre', asientoIconSize),
                    _buildLegendItem(const Color(0xFF0D47A1), 'Seleccionado', asientoIconSize),
                    _buildLegendItem(Colors.grey.shade600, 'Ocupado', asientoIconSize),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF0D47A1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.event_seat, color: Color(0xFF0D47A1), size: 18),
                      const SizedBox(width: 6),
                      const Text('Asientos: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          _asientosSeleccionadosTexto.isEmpty ? 'Ninguno' : _asientosSeleccionadosTexto,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF0D47A1), fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _totalSeleccionados == 0 ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TipoBoletosScreen(
                            asientosSeleccionados: _totalSeleccionados,
                            peliculaNombre: widget.peliculaNombre,
                            salaNombre: _nombreSala,
                            horario: widget.horario,
                            clienteId: widget.clienteId,
                            clienteNombre: widget.clienteNombre,
                            asientos: _asientosSeleccionadosLista,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Siguiente', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, double iconSize) {
    return Row(
      children: [
        Container(
          width: iconSize + 4,
          height: iconSize + 4,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 1, offset: const Offset(0, 1))]),
          child: Icon(Icons.event_seat, size: iconSize - 2, color: color == Colors.white ? const Color(0xFF0D47A1) : Colors.white),
        ),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }
}