import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/pelicula_model.dart';
import '../models/funcion_model.dart';
import 'pelicula_detalle_screen.dart';
import 'asientos_screen.dart';
import 'alimentos_screen.dart';
import 'carrito_screen.dart';
import 'mis_compras_screen.dart'; // ← NUEVO IMPORT
import 'perfil_screen.dart';

class ClienteHomeScreen extends StatefulWidget {
  final String? clienteId;
  final String? clienteNombre;

  const ClienteHomeScreen({
    super.key,
    this.clienteId,
    this.clienteNombre,
  });

  @override
  State<ClienteHomeScreen> createState() => _ClienteHomeScreenState();
}

class _ClienteHomeScreenState extends State<ClienteHomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  // ignore: unused_field
  String _sucursalSeleccionadaId = '';
  String _sucursalSeleccionadaNombre = '';
  List<String> _sucursalesNombres = [];
  DateTime _fechaSeleccionada = DateTime.now();
  int _puntosCliente = 0;
  String _nombreCliente = '';
  
  List<Pelicula> _peliculas = [];
  List<Funcion> _funciones = [];
  bool _isLoading = true;
  bool _isLoadingPerfil = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _cargarPeliculasYFunciones();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosUsuario() async {
    if (widget.clienteId == null) {
      setState(() {
        _nombreCliente = widget.clienteNombre ?? 'Cliente';
        _sucursalesNombres = ['Gran Patio', 'Misiones', 'Américas'];
        _sucursalSeleccionadaNombre = 'Gran Patio';
        _sucursalSeleccionadaId = 'Gran Patio';
        _isLoadingPerfil = false;
      });
      return;
    }
    
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.clienteId)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data();
        
        String nombre = data?['nombre'] ?? widget.clienteNombre ?? 'Cliente';
        final int puntos = (data?['puntos_cinepolis'] ?? 0) as int;
        
        List<dynamic> sucursalesList = data?['sucursales_preferidas_nombres'] ?? 
                                        data?['sucursales_preferidas'] ?? 
                                        data?['sucursales_favoritas'] ?? [];
        
        setState(() {
          _nombreCliente = nombre;
          _puntosCliente = puntos;
          
          if (sucursalesList.isNotEmpty) {
            _sucursalesNombres = sucursalesList.map((e) => e.toString()).toList();
            _sucursalSeleccionadaNombre = _sucursalesNombres.first;
            _sucursalSeleccionadaId = _sucursalSeleccionadaNombre;
          } else {
            _sucursalesNombres = ['Gran Patio', 'Misiones', 'Américas'];
            _sucursalSeleccionadaNombre = 'Gran Patio';
            _sucursalSeleccionadaId = 'Gran Patio';
          }
          
          _isLoadingPerfil = false;
        });
      } else {
        setState(() {
          _nombreCliente = widget.clienteNombre ?? 'Cliente';
          _sucursalesNombres = ['Gran Patio', 'Misiones', 'Américas'];
          _sucursalSeleccionadaNombre = 'Gran Patio';
          _sucursalSeleccionadaId = 'Gran Patio';
          _isLoadingPerfil = false;
        });
      }
    } catch (e) {
      setState(() {
        _nombreCliente = widget.clienteNombre ?? 'Cliente';
        _sucursalesNombres = ['Gran Patio', 'Misiones', 'Américas'];
        _sucursalSeleccionadaNombre = 'Gran Patio';
        _sucursalSeleccionadaId = 'Gran Patio';
        _isLoadingPerfil = false;
      });
    }
  }

  Future<void> _cargarPeliculasYFunciones() async {
    setState(() => _isLoading = true);
    
    // Cargar películas
    _firebaseService.getPeliculas().listen((peliculas) {
      if (mounted) {
        setState(() {
          _peliculas = peliculas;
        });
      }
    });
    
    // Cargar funciones
    _firebaseService.getFunciones().listen((funciones) async {
      // Cargar nombres de salas para cada función
      for (var funcion in funciones) {
        if (funcion.idSala.isNotEmpty && funcion.nombreSala.isEmpty) {
          final sala = await _firebaseService.getSalaById(funcion.idSala);
          if (sala != null) {
            funcion.nombreSala = sala.nombre;
          }
        }
      }
      if (mounted) {
        setState(() {
          _funciones = funciones;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _seleccionarFecha() async {
    DateTime tempFecha = _fechaSeleccionada;
    DateTime firstDate = DateTime.now();
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Seleccionar Fecha', textAlign: TextAlign.center),
              content: SizedBox(
                width: 320,
                height: 320,
                child: CalendarDatePicker(
                  initialDate: tempFecha,
                  firstDate: firstDate,
                  lastDate: firstDate.add(const Duration(days: 30)),
                  onDateChanged: (date) {
                    setStateDialog(() {
                      tempFecha = date;
                    });
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _fechaSeleccionada = tempFecha;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                  ),
                  child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Funcion> _getFuncionesPorPelicula(String peliculaId) {
    return _funciones.where((f) => f.idPelicula == peliculaId).toList();
  }

  String _formatearFecha(DateTime fecha) {
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${fecha.day} ${meses[fecha.month - 1]}';
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
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                  Text(
                    '¡Bienvenid@!',
                    style: GoogleFonts.roboto(fontSize: 12, color: Colors.white70),
                  ),
                  Text(
                    _nombreCliente,
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
          // Ícono del carrito
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarritoScreen(
                        clienteId: widget.clienteId,
                        clienteNombre: _nombreCliente,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          // Botón de perfil
          // Botón de perfil
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerfilScreen(
          clienteId: widget.clienteId,
          clienteNombre: _nombreCliente,
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
          // Tarjeta de puntos
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 30),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Puntos Cinépolis',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '$_puntosCliente pts',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Canjear',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar película...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0D47A1)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 12),
          // Filtros de fecha y sucursal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _seleccionarFecha,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: Color(0xFF0D47A1)),
                          const SizedBox(width: 8),
                          Text(
                            _formatearFecha(_fechaSeleccionada),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _isLoadingPerfil
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _sucursalSeleccionadaNombre.isEmpty && _sucursalesNombres.isNotEmpty 
                                  ? _sucursalesNombres.first 
                                  : (_sucursalSeleccionadaNombre.isEmpty ? null : _sucursalSeleccionadaNombre),
                              hint: const Text('Seleccionar sucursal'),
                              items: _sucursalesNombres.map((nombre) {
                                return DropdownMenuItem<String>(
                                  value: nombre,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_city, size: 18, color: Color(0xFF0D47A1)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          nombre,
                                          style: const TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _sucursalSeleccionadaNombre = value;
                                    _sucursalSeleccionadaId = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Lista de películas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildPeliculasList(),
          ),
        ],
      ),
      // ========== BOTTOM NAVIGATION BAR MODIFICADO ==========
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Cartelera'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Alimentos'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Mis compras'), // ← NUEVO
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlimentosScreen(
                  clienteId: widget.clienteId,
                  clienteNombre: _nombreCliente,
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarritoScreen(
                  clienteId: widget.clienteId,
                  clienteNombre: _nombreCliente,
                ),
              ),
            );
          } else if (index == 3) { // ← NUEVO
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MisComprasScreen(
                  clienteId: widget.clienteId,
                  clienteNombre: _nombreCliente,
                ),
              ),
            );
          }
        },
      ),
      // ========== FIN DE BOTTOM NAVIGATION BAR MODIFICADO ==========
    );
  }

  Widget _buildPeliculasList() {
    var peliculasFiltradas = List<Pelicula>.from(_peliculas);
    if (_searchQuery.isNotEmpty) {
      peliculasFiltradas = peliculasFiltradas
          .where((p) => p.nombre.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    
    if (peliculasFiltradas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay películas disponibles', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: peliculasFiltradas.length,
      itemBuilder: (context, index) {
        final pelicula = peliculasFiltradas[index];
        final funcionesPelicula = _getFuncionesPorPelicula(pelicula.id!);
        
        // Agrupar funciones por sala
        Map<String, List<Funcion>> funcionesPorSala = {};
        for (var f in funcionesPelicula) {
          final key = f.idSala;
          if (!funcionesPorSala.containsKey(key)) {
            funcionesPorSala[key] = [];
          }
          funcionesPorSala[key]!.add(f);
        }
        
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: pelicula.imagen != null && pelicula.imagen!.isNotEmpty
                          ? Image.network(
                              pelicula.imagen!,
                              width: 80,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.movie, size: 40, color: Color(0xFF0D47A1)),
                                );
                              },
                            )
                          : Container(
                              width: 80,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.movie, size: 40, color: Color(0xFF0D47A1)),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pelicula.nombre,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D47A1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pelicula.genero,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${pelicula.duracionMin} min',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  pelicula.clasificacion,
                                  style: const TextStyle(fontSize: 10, color: Colors.purple),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PeliculaDetalleScreen(
                                    pelicula: pelicula,
                                    clienteId: widget.clienteId,
                                    clienteNombre: _nombreCliente,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D47A1),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: const Size(0, 0),
                            ),
                            child: const Text(
                              'Ver más',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Horarios agrupados por sala
              if (funcionesPorSala.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: funcionesPorSala.entries.map((entry) {
                      final salaId = entry.key;
                      final funciones = entry.value;
                      final nombreSala = funciones.first.nombreSala.isNotEmpty 
                          ? funciones.first.nombreSala 
                          : 'Sala ${salaId.substring(salaId.length - 1)}';
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              nombreSala,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: funciones.map((funcion) {
                              final hora = '${funcion.fechaHora.hour.toString().padLeft(2, '0')}:${funcion.fechaHora.minute.toString().padLeft(2, '0')}';
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AsientosScreen(
                                        peliculaNombre: pelicula.nombre,
                                        salaId: funcion.idSala,
                                        horario: hora,
                                        clienteId: widget.clienteId,
                                        clienteNombre: _nombreCliente,
                                        funcionId: funcion.id!,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF0D47A1).withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    hora,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0D47A1)),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}