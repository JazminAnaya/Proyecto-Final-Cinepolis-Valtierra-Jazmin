import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/empleado_model.dart';

class EmpleadosFormScreen extends StatefulWidget {
  final Empleado? empleado;

  const EmpleadosFormScreen({super.key, this.empleado});

  @override
  State<EmpleadosFormScreen> createState() => _EmpleadosFormScreenState();
}

class _EmpleadosFormScreenState extends State<EmpleadosFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  late TextEditingController _rfcController;
  late TextEditingController _puestoController;
  late TextEditingController _salarioController;
  late TextEditingController _idComplejoController;

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.empleado != null;
    _nombreController = TextEditingController(text: widget.empleado?.nombre ?? '');
    _telefonoController = TextEditingController(text: widget.empleado?.telefono ?? '');
    _emailController = TextEditingController(text: widget.empleado?.email ?? '');
    _rfcController = TextEditingController(text: widget.empleado?.rfc ?? '');
    _puestoController = TextEditingController(text: widget.empleado?.puesto ?? '');
    _salarioController = TextEditingController(text: widget.empleado?.salario.toString() ?? '');
    _idComplejoController = TextEditingController(text: widget.empleado?.idComplejo ?? 'COMP-001');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _rfcController.dispose();
    _puestoController.dispose();
    _salarioController.dispose();
    _idComplejoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final empleado = Empleado(
      id: widget.empleado?.id,
      nombre: _nombreController.text.trim(),
      email: _emailController.text.trim(),
      telefono: _telefonoController.text.trim(),
      rfc: _rfcController.text.trim().toUpperCase(),
      puesto: _puestoController.text.trim(),
      salario: double.tryParse(_salarioController.text) ?? 0,
      idComplejo: _idComplejoController.text.trim(),
    );

    bool success;
    if (_isEditing) {
      success = await _firebaseService.updateEmpleado(empleado);
    } else {
      final id = await _firebaseService.createEmpleado(empleado);
      success = id != null;
    }

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Empleado actualizado' : 'Empleado creado'),
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
          _isEditing ? 'Editar Empleado' : 'Nuevo Empleado',
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
                    const Icon(Icons.badge, color: Color(0xFF0D47A1)),
                    const SizedBox(width: 10),
                    Text(
                      'ID (no editable): ${widget.empleado!.id?.substring(0, 6)}...',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            _buildTextField(_nombreController, 'Nombre Completo', Icons.person, true),
            const SizedBox(height: 16),
            _buildTextField(_telefonoController, 'Teléfono', Icons.phone, true, TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField(_emailController, 'Correo Electrónico', Icons.email, true, TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(_rfcController, 'RFC', Icons.badge, false, TextInputType.text),
            const SizedBox(height: 16),
            _buildTextField(_puestoController, 'Puesto', Icons.work, true),
            const SizedBox(height: 16),
            _buildTextField(_salarioController, 'Salario', Icons.attach_money, true, TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(_idComplejoController, 'ID Complejo', Icons.business, true),
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
              if (label == 'Correo Electrónico' && !value.contains('@')) {
                return 'Ingrese un correo válido';
              }
              if (label == 'Teléfono' && value.length < 10) {
                return 'Ingrese un teléfono válido (mínimo 10 dígitos)';
              }
              return null;
            }
          : null,
    );
  }
}