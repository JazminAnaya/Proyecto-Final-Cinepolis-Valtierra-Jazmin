import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/complejo_model.dart';

class ComplejosFormScreen extends StatefulWidget {
  final Complejo? complejo;

  const ComplejosFormScreen({super.key, this.complejo});

  @override
  State<ComplejosFormScreen> createState() => _ComplejosFormScreenState();
}

class _ComplejosFormScreenState extends State<ComplejosFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  late TextEditingController _nombreController;
  late TextEditingController _ciudadController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoController;
  late String _estadoSeleccionado;

  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _estados = ['Activo', 'Inactivo'];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.complejo != null;
    _nombreController = TextEditingController(text: widget.complejo?.nombre ?? '');
    _ciudadController = TextEditingController(text: widget.complejo?.ciudad ?? '');
    _direccionController = TextEditingController(text: widget.complejo?.direccion ?? '');
    _telefonoController = TextEditingController(text: widget.complejo?.telefono ?? '');
    _estadoSeleccionado = widget.complejo?.estado ?? 'Activo';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _ciudadController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final complejo = Complejo(
      id: widget.complejo?.id,
      nombre: _nombreController.text.trim(),
      ciudad: _ciudadController.text.trim(),
      direccion: _direccionController.text.trim(),
      telefono: _telefonoController.text.trim(),
      estado: _estadoSeleccionado,
    );

    bool success;
    if (_isEditing) {
      success = await _firebaseService.updateComplejo(complejo);
    } else {
      final id = await _firebaseService.createComplejo(complejo);
      success = id != null;
    }

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Sucursal actualizada' : 'Sucursal creada'),
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
          _isEditing ? 'Editar Sucursal' : 'Nueva Sucursal',
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
                    const Icon(Icons.business, color: Color(0xFF0D47A1)),
                    const SizedBox(width: 10),
                    Text(
                      'ID: ${widget.complejo!.id}',  // ID completo
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            _buildTextField(_nombreController, 'Nombre de la Sucursal', Icons.business, true),
            const SizedBox(height: 16),
            _buildTextField(_ciudadController, 'Ciudad', Icons.location_city, true),
            const SizedBox(height: 16),
            _buildTextField(_direccionController, 'Dirección', Icons.location_on, true),
            const SizedBox(height: 16),
            _buildTextField(_telefonoController, 'Teléfono', Icons.phone, true, TextInputType.phone),
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
              if (label == 'Teléfono' && value.length < 10) {
                return 'Ingrese un teléfono válido (mínimo 10 dígitos)';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildEstadoDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _estadoSeleccionado,
      decoration: InputDecoration(
        labelText: 'Estado',
        prefixIcon: const Icon(Icons.check_circle_outline, color: Color(0xFF0D47A1)),
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
      items: _estados.map((String estado) {
        return DropdownMenuItem<String>(
          value: estado,
          child: Row(
            children: [
              Icon(
                estado == 'Activo' ? Icons.check_circle : Icons.cancel,
                color: estado == 'Activo' ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(estado),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _estadoSeleccionado = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Seleccione un estado';
        }
        return null;
      },
    );
  }
}