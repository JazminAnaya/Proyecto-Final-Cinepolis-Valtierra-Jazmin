import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _paisController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Fecha de nacimiento
  DateTime? _fechaNacimiento;
  
  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _ciudadController.dispose();
    _paisController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Selector de fecha SIMPLE
  Future<void> _seleccionarFecha() async {
    DateTime tempFecha = _fechaNacimiento ?? DateTime.now().subtract(const Duration(days: 365 * 18));
    DateTime firstDate = DateTime(1950);
    DateTime lastDate = DateTime.now();
    
    if (tempFecha.isBefore(firstDate)) {
      tempFecha = firstDate;
    }
    if (tempFecha.isAfter(lastDate)) {
      tempFecha = lastDate;
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
                  lastDate: lastDate,
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
                      _fechaNacimiento = tempFecha;
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

  Future<void> _registro() async {
    // Validaciones
    if (_nombreController.text.trim().isEmpty) {
      setState(() => _errorMessage = '❌ Ingrese su nombre completo');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = '❌ Ingrese su correo electrónico');
      return;
    }
    if (!_emailController.text.contains('@') || !_emailController.text.contains('.')) {
      setState(() => _errorMessage = '❌ Ingrese un correo electrónico válido (ejemplo@correo.com)');
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      setState(() => _errorMessage = '❌ Ingrese una contraseña');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = '❌ La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = '❌ Las contraseñas no coinciden');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      print('📝 Intentando crear usuario con email: ${_emailController.text.trim().toLowerCase()}');
      
      // Crear usuario en Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
      );
      
      print('✅ Usuario creado en Authentication: ${userCredential.user!.uid}');

      // Guardar datos adicionales en Firestore
      Map<String, dynamic> userData = {
        'nombre': _nombreController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'telefono': _telefonoController.text.trim(),
        'ciudad': _ciudadController.text.trim(),
        'pais': _paisController.text.trim(),
        'fecha_registro': DateTime.now().toIso8601String(),
        'rol': 'cliente',
        'puntos_cinepolis': 0,
        'ha_seleccionado_sucursales': false,  // Campo para saber si ya eligió sucursales
      };
      
      if (_fechaNacimiento != null) {
        userData['fecha_nacimiento'] = _fechaNacimiento!.toIso8601String();
      }

      await _firestore.collection('Usuarios').doc(userCredential.user!.uid).set(userData);
      print('✅ Datos guardados en Firestore');

      if (mounted) {
        setState(() {
          _successMessage = '✅ ¡Cuenta creada exitosamente! Redirigiendo...';
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ¡Cuenta creada exitosamente!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      setState(() {
        _isLoading = false;
        if (e.code == 'email-already-in-use') {
          _errorMessage = '⚠️ Este correo ya está registrado. Usa otro correo o inicia sesión.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = '❌ Correo electrónico inválido. Verifica el formato.';
        } else if (e.code == 'weak-password') {
          _errorMessage = '❌ La contraseña es muy débil. Usa al menos 6 caracteres.';
        } else if (e.code == 'operation-not-allowed') {
          _errorMessage = '⚠️ Error de configuración. Contacta al administrador. (Email/Password no habilitado)';
        } else {
          _errorMessage = '❌ Error: ${e.message}';
        }
      });
    } catch (e) {
      print('❌ Error general: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '⚠️ Error de conexión: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bluePrimary = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Crear Nuevo Usuario',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: bluePrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Nombre Completo
            _buildTextField(
              _nombreController,
              'Nombre Completo',
              'Ej: Juan Pérez',
              Icons.person,
              true,
            ),
            const SizedBox(height: 16),
            
            // Correo Electrónico
            _buildTextField(
              _emailController,
              'Correo Electrónico',
              'ejemplo@correo.com',
              Icons.email,
              true,
              TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            
            // Teléfono
            _buildTextField(
              _telefonoController,
              'Teléfono',
              'Ej: 656-123-4567',
              Icons.phone,
              false,
              TextInputType.phone,
            ),
            const SizedBox(height: 16),
            
            // Ciudad
            _buildTextField(
              _ciudadController,
              'Ciudad',
              'Ej: Ciudad Juárez',
              Icons.location_city,
              false,
            ),
            const SizedBox(height: 16),
            
            // País
            _buildTextField(
              _paisController,
              'País',
              'Ej: México',
              Icons.public,
              false,
            ),
            const SizedBox(height: 16),
            
            // Fecha de Nacimiento
            _buildFechaField(),
            const SizedBox(height: 16),
            
            // Contraseña
            _buildPasswordField(
              _passwordController,
              'Contraseña',
              'Mínimo 6 caracteres',
              _isPasswordVisible,
              () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            const SizedBox(height: 16),
            
            // Confirmar Contraseña
            _buildPasswordField(
              _confirmPasswordController,
              'Confirmar Contraseña',
              'Repite tu contraseña',
              _isConfirmPasswordVisible,
              () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
            
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            if (_successMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.green, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 30),
            
            // Botón Crear Cuenta
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bluePrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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
                    : const Text(
                        'Crear Cuenta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Link para volver al login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('¿Ya tienes cuenta?'),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(color: bluePrimary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
    bool required, [
    TextInputType? keyboardType,
  ]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
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
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    String hint,
    bool isVisible,
    VoidCallback toggleVisibility,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0D47A1)),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey,
              ),
              onPressed: toggleVisibility,
            ),
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
        ),
      ],
    );
  }

  Widget _buildFechaField() {
    String textoFecha = 'Seleccionar fecha de nacimiento';
    
    if (_fechaNacimiento != null) {
      textoFecha = '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha de Nacimiento',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _seleccionarFecha,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF0D47A1)),
                const SizedBox(width: 12),
                Text(
                  textoFecha,
                  style: TextStyle(
                    fontSize: 14,
                    color: _fechaNacimiento != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}