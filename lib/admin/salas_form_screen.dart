import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/sala_model.dart';
import '../models/complejo_model.dart';

class SalasFormScreen extends StatefulWidget {
  final Sala? sala;

  const SalasFormScreen({super.key, this.sala});

  @override
  State<SalasFormScreen> createState() => _SalasFormScreenState();
}

class _SalasFormScreenState extends State<SalasFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  late TextEditingController _nombreController;
  late TextEditingController _capacidadController;
  late TextEditingController _tipoController;
  
  String? _complejoSeleccionadoId;
  String _complejoSeleccionadoNombre = '';
  List<Complejo> _complejos = [];
  bool _isLoadingComplejos = true;

  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _tiposSala = [
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
    _isEditing = widget.sala != null;
    _nombreController = TextEditingController(text: widget.sala?.nombre ?? '');
    _capacidadController = TextEditingController(text: widget.sala?.capacidad.toString() ?? '');
    _tipoController = TextEditingController(text: widget.sala?.tipo ?? 'Sala Normal');
    _complejoSeleccionadoId = widget.sala?.idComplejo;
    _complejoSeleccionadoNombre = widget.sala?.nombreComplejo ?? '';
    _cargarComplejos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _capacidadController.dispose();
    _tipoController.dispose();
    super.dispose();
  }

  Future<void> _cargarComplejos() async {
    setState(() => _isLoadingComplejos = true);
    _firebaseService.getComplejos().listen((complejos) {
      if (mounted) {
        setState(() {
          _complejos = complejos;
          _isLoadingComplejos = false;
          
          // Si estamos editando y hay un complejo seleccionado, buscar su nombre
          if (_isEditing && _complejoSeleccionadoId != null && _complejoSeleccionadoId!.isNotEmpty) {
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_complejoSeleccionadoId == null || _complejoSeleccionadoId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una sucursal'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final sala = Sala(
      id: widget.sala?.id,
      nombre: _nombreController.text.trim(),
      capacidad: int.tryParse(_capacidadController.text) ?? 0,
      tipo: _tipoController.text.trim(),
      idComplejo: _complejoSeleccionadoId!,
      nombreComplejo: _complejoSeleccionadoNombre, // Solo para mostrar, no se guarda
    );

    bool success;
    if (_isEditing) {
      success = await _firebaseService.updateSala(sala);
    } else {
      final id = await _firebaseService.createSala(sala);
      success = id != null;
    }

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Sala actualizada' : 'Sala creada'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Sala' : 'Nueva Sala',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.theaters, color: Color(0xFF0D47A1)),
                    const SizedBox(width: 10),
                    Text(
                      'ID: ${widget.sala!.id}',  // ID completo
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            _buildTextField(_nombreController, 'Nombre de la Sala', Icons.theaters, true),
            const SizedBox(height: 16),
            _buildTextField(_capacidadController, 'Capacidad', Icons.people, true, TextInputType.number),
            const SizedBox(height: 16),
            _buildTipoDropdown(),
            const SizedBox(height: 16),
            _buildComplejoDropdown(),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      bool required, [TextInputType? keyboardType]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
        ),
      ),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es requerido';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildTipoDropdown() {
    String? valorActual = _tipoController.text.isNotEmpty ? _tipoController.text : null;
    
    if (valorActual != null && !_tiposSala.contains(valorActual)) {
      valorActual = _tiposSala.first;
      _tipoController.text = valorActual;
    }
    
    return DropdownButtonFormField<String>(
      initialValue: valorActual,
      decoration: InputDecoration(
        labelText: 'Tipo de Sala',
        prefixIcon: const Icon(Icons.category, color: Color(0xFF0D47A1)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
        ),
      ),
      items: _tiposSala.map((String tipo) {
        return DropdownMenuItem<String>(
          value: tipo,
          child: Row(
            children: [
              Icon(
                tipo.contains('VIP') ? Icons.star : Icons.movie,
                color: const Color(0xFF0D47A1),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(tipo),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _tipoController.text = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Seleccione un tipo de sala';
        }
        return null;
      },
    );
  }

  Widget _buildComplejoDropdown() {
    String? dropdownValue;
    if (_complejoSeleccionadoId != null && _complejoSeleccionadoId!.isNotEmpty) {
      final existe = _complejos.any((c) => c.id == _complejoSeleccionadoId);
      if (existe) {
        dropdownValue = _complejoSeleccionadoId;
      } else if (_complejos.isNotEmpty) {
        dropdownValue = _complejos.first.id;
        _complejoSeleccionadoId = dropdownValue;
        _complejoSeleccionadoNombre = _complejos.first.nombre;
      }
    } else if (_complejos.isNotEmpty) {
      dropdownValue = _complejos.first.id;
      _complejoSeleccionadoId = dropdownValue;
      _complejoSeleccionadoNombre = _complejos.first.nombre;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sucursal', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        if (_isLoadingComplejos)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Cargando sucursales...'),
              ],
            ),
          )
        else if (_complejos.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text('No hay sucursales registradas. Cree una primero.'),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Seleccione una sucursal'),
                ),
                value: dropdownValue,
                items: _complejos.map((Complejo complejo) {
                  return DropdownMenuItem<String>(
                    value: complejo.id,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.location_city, color: Color(0xFF0D47A1), size: 20),
                          const SizedBox(width: 8),
                          Text(complejo.nombre),
                          const SizedBox(width: 8),
                          Text(
                            '(${complejo.ciudad})',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
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
      ],
    );
  }
}