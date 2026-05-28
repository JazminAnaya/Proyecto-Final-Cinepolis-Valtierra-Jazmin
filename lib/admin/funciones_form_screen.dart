import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/funcion_model.dart';
import '../models/pelicula_model.dart';
import '../models/sala_model.dart';
import '../models/complejo_model.dart';

class FuncionesFormScreen extends StatefulWidget {
  final Funcion? funcion;

  const FuncionesFormScreen({super.key, this.funcion});

  @override
  State<FuncionesFormScreen> createState() => _FuncionesFormScreenState();
}

class _FuncionesFormScreenState extends State<FuncionesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  late TextEditingController _precioController;
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  late String _estadoSeleccionado;
  late String _formatoSeleccionado;
  
  String? _peliculaSeleccionadaId;
  String _peliculaSeleccionadaNombre = '';
  String? _salaSeleccionadaId;
  String _salaSeleccionadaNombre = '';
  String? _complejoSeleccionadoId;
  String _complejoSeleccionadoNombre = '';

  bool _isLoading = false;
  bool _isEditing = false;
  bool _isLoadingPeliculas = true;
  bool _isLoadingSalas = true;
  bool _isLoadingComplejos = true;
  
  List<Pelicula> _peliculas = [];
  List<Sala> _salas = [];
  List<Complejo> _complejos = [];

  final List<String> _estados = ['Disponible', 'Cancelada', 'Completada'];
  final List<String> _formatos = ['2D', '3D', '4DX', 'IMAX', 'VIP 2D', 'VIP 3D'];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.funcion != null;
    _precioController = TextEditingController(text: widget.funcion?.precioBase.toString() ?? '');
    
    print('========== EDITANDO FUNCIÓN ==========');
    print('ID: ${widget.funcion?.id}');
    
    // CORREGIDO: Usar una variable local segura
    final funcionLocal = widget.funcion;
    if (funcionLocal != null) {
      final fechaOriginal = funcionLocal.fechaHora;
      // ignore: unnecessary_null_comparison
        _fechaSeleccionada = fechaOriginal;
        _horaSeleccionada = TimeOfDay.fromDateTime(fechaOriginal);
        print('Fecha cargada: $_fechaSeleccionada');
        print('Hora cargada: ${_horaSeleccionada?.hour}:${_horaSeleccionada?.minute}');
    }
    
    _estadoSeleccionado = widget.funcion?.estado ?? 'Disponible';
    _formatoSeleccionado = widget.funcion?.formato ?? '2D';
    _peliculaSeleccionadaId = widget.funcion?.idPelicula;
    _salaSeleccionadaId = widget.funcion?.idSala;
    _complejoSeleccionadoId = widget.funcion?.idComplejo;
    
    _cargarPeliculas();
    _cargarSalas();
    _cargarComplejos();
  }

  @override
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _cargarPeliculas() async {
    setState(() => _isLoadingPeliculas = true);
    _firebaseService.getPeliculas().listen((peliculas) {
      if (mounted) {
        setState(() {
          _peliculas = peliculas;
          _isLoadingPeliculas = false;
          if (_isEditing && _peliculaSeleccionadaId != null) {
            final pelicula = _peliculas.firstWhere(
              (p) => p.id == _peliculaSeleccionadaId,
              orElse: () => Pelicula(id: '', nombre: '', clasificacion: '', director: '', duracionMin: 0, genero: '', idioma: '', sinopsis: ''),
            );
            if (pelicula.id!.isNotEmpty) {
              _peliculaSeleccionadaNombre = pelicula.nombre;
            }
          }
        });
      }
    });
  }

  Future<void> _cargarSalas() async {
    setState(() => _isLoadingSalas = true);
    _firebaseService.getSalas().listen((salas) {
      if (mounted) {
        setState(() {
          _salas = salas;
          _isLoadingSalas = false;
          if (_isEditing && _salaSeleccionadaId != null) {
            final sala = _salas.firstWhere(
              (s) => s.id == _salaSeleccionadaId,
              orElse: () => Sala(id: '', nombre: '', capacidad: 0, tipo: '', idComplejo: ''),
            );
            if (sala.id!.isNotEmpty) {
              _salaSeleccionadaNombre = sala.nombre;
            }
          }
        });
      }
    });
  }

  Future<void> _cargarComplejos() async {
    setState(() => _isLoadingComplejos = true);
    _firebaseService.getComplejos().listen((complejos) {
      if (mounted) {
        setState(() {
          _complejos = complejos;
          _isLoadingComplejos = false;
          if (_isEditing && _complejoSeleccionadoId != null) {
            final complejo = _complejos.firstWhere(
              (c) => c.id == _complejoSeleccionadoId,
              orElse: () => Complejo(id: '', nombre: '', ciudad: '', direccion: '', telefono: '', estado: ''),
            );
            if (complejo.id!.isNotEmpty) {
              _complejoSeleccionadoNombre = complejo.nombre;
            }
          }
        });
      }
    });
  }

  // Selector de fecha MANUAL
  Future<void> _seleccionarFechaManual() async {
    DateTime tempFecha = _fechaSeleccionada ?? DateTime.now();
    DateTime firstDate = DateTime.now();
    
    if (tempFecha.isBefore(firstDate)) {
      tempFecha = firstDate;
    }
    
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
                  lastDate: firstDate.add(const Duration(days: 365)),
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
                    _seleccionarHoraManual();
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

  // Selector de hora MANUAL
  Future<void> _seleccionarHoraManual() async {
    int tempHora = _horaSeleccionada?.hour ?? 12;
    int tempMinuto = _horaSeleccionada?.minute ?? 0;
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Seleccionar Hora', textAlign: TextAlign.center),
              content: SizedBox(
                width: 300,
                height: 220,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hora
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_drop_up, size: 40),
                              onPressed: () => setStateDialog(() => tempHora = (tempHora + 1) % 24),
                            ),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  tempHora.toString().padLeft(2, '0'),
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_drop_down, size: 40),
                              onPressed: () => setStateDialog(() => tempHora = (tempHora - 1 + 24) % 24),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        const Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 20),
                        // Minuto
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_drop_up, size: 40),
                              onPressed: () => setStateDialog(() => tempMinuto = (tempMinuto + 1) % 60),
                            ),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  tempMinuto.toString().padLeft(2, '0'),
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_drop_down, size: 40),
                              onPressed: () => setStateDialog(() => tempMinuto = (tempMinuto - 1 + 60) % 60),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
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
                      _horaSeleccionada = TimeOfDay(hour: tempHora, minute: tempMinuto);
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

  // Obtener fecha y hora combinada
  DateTime? get fechaHoraCombinada {
    if (_fechaSeleccionada != null && _horaSeleccionada != null) {
      return DateTime(
        _fechaSeleccionada!.year,
        _fechaSeleccionada!.month,
        _fechaSeleccionada!.day,
        _horaSeleccionada!.hour,
        _horaSeleccionada!.minute,
      );
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_peliculaSeleccionadaId == null) {
      _mostrarMensaje('Seleccione una película', Colors.red);
      return;
    }
    
    if (_salaSeleccionadaId == null) {
      _mostrarMensaje('Seleccione una sala', Colors.red);
      return;
    }
    
    if (_complejoSeleccionadoId == null) {
      _mostrarMensaje('Seleccione una sucursal', Colors.red);
      return;
    }
    
    final fechaHora = fechaHoraCombinada;
    if (fechaHora == null) {
      _mostrarMensaje('Seleccione una fecha y hora', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final funcion = Funcion(
      id: _isEditing ? widget.funcion!.id : null,
      estado: _estadoSeleccionado,
      fechaHora: fechaHora,
      formato: _formatoSeleccionado,
      idPelicula: _peliculaSeleccionadaId!,
      nombrePelicula: _peliculaSeleccionadaNombre,
      idSala: _salaSeleccionadaId!,
      nombreSala: _salaSeleccionadaNombre,
      idComplejo: _complejoSeleccionadoId!,
      nombreComplejo: _complejoSeleccionadoNombre,
      precioBase: double.tryParse(_precioController.text) ?? 0,
    );

    print('========== GUARDANDO FUNCIÓN ==========');
    print('ID: ${funcion.id}');
    print('Fecha: ${funcion.fechaHora}');

    bool success;
    if (_isEditing) {
      print('Actualizando función existente...');
      success = await _firebaseService.updateFuncion(funcion);
    } else {
      print('Creando nueva función...');
      final id = await _firebaseService.createFuncion(funcion);
      success = id != null;
    }

    setState(() => _isLoading = false);

    if (success) {
      _mostrarMensaje(_isEditing ? 'Función actualizada' : 'Función creada', Colors.green);
      Navigator.pop(context, true);
    } else {
      _mostrarMensaje('Error al guardar', Colors.red);
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Función' : 'Nueva Función',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_isEditing)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: Color(0xFF0D47A1)),
                    const SizedBox(width: 10),
                    Text('ID: ${widget.funcion?.id}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            _buildPeliculaDropdown(),
            const SizedBox(height: 16),
            _buildSalaDropdown(),
            const SizedBox(height: 16),
            _buildComplejoDropdown(),
            const SizedBox(height: 16),
            _buildFechaHoraField(),
            const SizedBox(height: 16),
            _buildFormatoDropdown(),
            const SizedBox(height: 16),
            _buildTextField(_precioController, 'Precio Base', Icons.attach_money, true, TextInputType.number),
            const SizedBox(height: 16),
            _buildEstadoDropdown(),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFF0D47A1)),
                    ),
                    child: const Text('Cancelar', style: TextStyle(color: Color(0xFF0D47A1))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                        : const Text('Listo', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool required, [TextInputType? keyboardType]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2)),
      ),
      validator: required ? (value) => value == null || value.isEmpty ? 'Este campo es requerido' : null : null,
    );
  }

  Widget _buildPeliculaDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Película *', style: TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      _isLoadingPeliculas
          ? Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: const Row(children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 12), Text('Cargando películas...')]))
          : _peliculas.isEmpty
              ? Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: const Text('No hay películas registradas'))
              : Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Seleccione una película')),
                      value: _peliculaSeleccionadaId,
                      items: _peliculas.map((p) => DropdownMenuItem(value: p.id, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [const Icon(Icons.movie, color: Color(0xFF0D47A1), size: 20), const SizedBox(width: 8), Text(p.nombre), const SizedBox(width: 8), Text('(${p.genero})', style: const TextStyle(color: Colors.grey, fontSize: 12))])))).toList(),
                      onChanged: (value) {
                        setState(() {
                          _peliculaSeleccionadaId = value;
                          final pelicula = _peliculas.firstWhere((p) => p.id == value);
                          _peliculaSeleccionadaNombre = pelicula.nombre;
                        });
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
    ]);
  }

  Widget _buildSalaDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Sala *', style: TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      _isLoadingSalas
          ? Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: const Row(children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 12), Text('Cargando salas...')]))
          : _salas.isEmpty
              ? Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: const Text('No hay salas registradas'))
              : Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Seleccione una sala')),
                      value: _salaSeleccionadaId,
                      items: _salas.map((s) => DropdownMenuItem(value: s.id, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [const Icon(Icons.theaters, color: Color(0xFF0D47A1), size: 20), const SizedBox(width: 8), Text(s.nombre), const SizedBox(width: 8), Text('(${s.tipo}, Cap: ${s.capacidad})', style: const TextStyle(color: Colors.grey, fontSize: 12))])))).toList(),
                      onChanged: (value) {
                        setState(() {
                          _salaSeleccionadaId = value;
                          final sala = _salas.firstWhere((s) => s.id == value);
                          _salaSeleccionadaNombre = sala.nombre;
                        });
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
    ]);
  }

  Widget _buildComplejoDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Sucursal *', style: TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      _isLoadingComplejos
          ? Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: const Row(children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 12), Text('Cargando sucursales...')]))
          : _complejos.isEmpty
              ? Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: const Text('No hay sucursales registradas'))
              : Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Seleccione una sucursal')),
                      value: _complejoSeleccionadoId,
                      items: _complejos.map((c) => DropdownMenuItem(value: c.id, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [const Icon(Icons.location_city, color: Color(0xFF0D47A1), size: 20), const SizedBox(width: 8), Text(c.nombre), const SizedBox(width: 8), Text('(${c.ciudad})', style: const TextStyle(color: Colors.grey, fontSize: 12))])))).toList(),
                      onChanged: (value) {
                        setState(() {
                          _complejoSeleccionadoId = value;
                          final complejo = _complejos.firstWhere((c) => c.id == value);
                          _complejoSeleccionadoNombre = complejo.nombre;
                        });
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
    ]);
  }

  Widget _buildFechaHoraField() {
    String textoFecha = 'Seleccionar fecha';
    String textoHora = 'Seleccionar hora';
    
    if (_fechaSeleccionada != null) {
      textoFecha = '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}';
    }
    
    if (_horaSeleccionada != null) {
      textoHora = '${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}';
    }
    
    final bool fechaCompleta = _fechaSeleccionada != null && _horaSeleccionada != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fecha y Hora *', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _seleccionarFechaManual,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF0D47A1), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          textoFecha,
                          style: TextStyle(
                            fontSize: 14,
                            color: _fechaSeleccionada != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: _fechaSeleccionada != null ? _seleccionarHoraManual : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: _fechaSeleccionada != null ? Colors.white : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF0D47A1), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          textoHora,
                          style: TextStyle(
                            fontSize: 14,
                            color: _horaSeleccionada != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (fechaCompleta)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Fecha seleccionada: ${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year} ${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          ),
      ],
    );
  }

  Widget _buildFormatoDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _formatoSeleccionado,
      decoration: InputDecoration(
        labelText: 'Formato',
        prefixIcon: const Icon(Icons.movie, color: Color(0xFF0D47A1)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2)),
      ),
      items: _formatos.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
      onChanged: (value) => setState(() => _formatoSeleccionado = value!),
    );
  }

  Widget _buildEstadoDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _estadoSeleccionado,
      decoration: InputDecoration(
        labelText: 'Estado',
        prefixIcon: const Icon(Icons.circle, color: Color(0xFF0D47A1)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2)),
      ),
      items: _estados.map((estado) {
        Color color;
        switch (estado) {
          case 'Disponible': color = Colors.green; break;
          case 'Cancelada': color = Colors.red; break;
          case 'Completada': color = Colors.blue; break;
          default: color = Colors.grey;
        }
        return DropdownMenuItem(value: estado, child: Row(children: [Icon(Icons.circle, color: color, size: 16), const SizedBox(width: 8), Text(estado)]));
      }).toList(),
      onChanged: (value) => setState(() => _estadoSeleccionado = value!),
    );
  }
}