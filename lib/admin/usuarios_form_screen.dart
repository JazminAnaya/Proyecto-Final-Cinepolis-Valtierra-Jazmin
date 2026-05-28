import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/usuario_model.dart';

class UsuariosFormScreen extends StatefulWidget {
  final Usuario? usuario;

  const UsuariosFormScreen({super.key, this.usuario});

  @override
  State<UsuariosFormScreen> createState() => _UsuariosFormScreenState();
}

class _UsuariosFormScreenState extends State<UsuariosFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _puntosController;
  late TextEditingController _ciudadController;
  late TextEditingController _paisController;
  late TextEditingController _fechaNacimientoController;

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.usuario != null;
    _nombreController = TextEditingController(text: widget.usuario?.nombre ?? '');
    _emailController = TextEditingController(text: widget.usuario?.email ?? '');
    _telefonoController = TextEditingController(text: widget.usuario?.telefono ?? '');
    _puntosController = TextEditingController(text: widget.usuario?.puntosCinepolis.toString() ?? '0');
    _ciudadController = TextEditingController(text: widget.usuario?.ciudad ?? '');
    _paisController = TextEditingController(text: widget.usuario?.pais ?? '');
    _fechaNacimientoController = TextEditingController(text: widget.usuario?.fechaNacimiento ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _puntosController.dispose();
    _ciudadController.dispose();
    _paisController.dispose();
    _fechaNacimientoController.dispose();
    super.dispose();
  }

  String _getNivelPorPuntos(int puntos) {
    if (puntos >= 500) return 'Platinum';
    if (puntos >= 200) return 'Gold';
    if (puntos >= 50) return 'Silver';
    return 'Fan';
  }

  Color _getNivelColorPorPuntos(int puntos) {
    if (puntos >= 500) return Colors.blueGrey;
    if (puntos >= 200) return Colors.amber;
    if (puntos >= 50) return Colors.grey;
    return Colors.brown;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final usuario = Usuario(
      id: widget.usuario?.id,
      nombre: _nombreController.text.trim(),
      email: _emailController.text.trim(),
      telefono: _telefonoController.text.trim(),
      puntosCinepolis: int.tryParse(_puntosController.text) ?? 0,
      ciudad: _ciudadController.text.trim(),
      pais: _paisController.text.trim(),
      fechaNacimiento: _fechaNacimientoController.text.trim(),
    );

    bool success;
    if (_isEditing) {
      success = await _firebaseService.updateUsuario(usuario);
    } else {
      final id = await _firebaseService.createUsuario(usuario);
      success = id != null;
    }

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Usuario actualizado' : 'Usuario creado'),
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
          _isEditing ? 'Editar Usuario' : 'Nuevo Usuario',
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
                    const Icon(Icons.person, color: Color(0xFF0D47A1)),
                    const SizedBox(width: 10),
                    Text(
                      'ID: ${widget.usuario!.id}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            _buildTextField(_nombreController, 'Nombre Completo', Icons.person, true),
            const SizedBox(height: 16),
            _buildTextField(_emailController, 'Correo Electrónico', Icons.email, true, TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(_telefonoController, 'Teléfono', Icons.phone, true, TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField(_ciudadController, 'Ciudad', Icons.location_city, false),
            const SizedBox(height: 16),
            _buildTextField(_paisController, 'País', Icons.public, false),
            const SizedBox(height: 16),
            _buildTextField(_fechaNacimientoController, 'Fecha de Nacimiento (AAAA-MM-DD)', Icons.cake, false),
            const SizedBox(height: 16),
            _buildTextField(_puntosController, 'Puntos Cinépolis', Icons.star, true, TextInputType.number),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Color(0xFF0D47A1)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nivel del Usuario:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getNivelColorPorPuntos(int.tryParse(_puntosController.text) ?? 0).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getNivelPorPuntos(int.tryParse(_puntosController.text) ?? 0),
                                style: TextStyle(
                                  color: _getNivelColorPorPuntos(int.tryParse(_puntosController.text) ?? 0),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_puntosController.text} puntos',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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