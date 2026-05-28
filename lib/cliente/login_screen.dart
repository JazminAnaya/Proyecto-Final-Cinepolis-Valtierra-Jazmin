import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cliente_home_screen.dart';
import 'registro_screen.dart';
import 'seleccionar_sucursales_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _guardarDatosUsuario(String userId, String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('clienteId', userId);
    await prefs.setString('clienteNombre', nombre);
    print('✅ Datos guardados en SharedPreferences - ID: $userId, Nombre: $nombre');
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _mostrarMensaje('Por favor ingrese email y contraseña', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      final String userId = userCredential.user!.uid;
      print('=== USUARIO AUTENTICADO ===');
      print('UID de FirebaseAuth: $userId');
      
      // Verificar si el usuario existe en Firestore
      final DocumentSnapshot userDoc = await _firestore.collection('Usuarios').doc(userId).get();
      
      if (userDoc.exists) {
        final Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        final bool haSeleccionado = data?['ha_seleccionado_sucursales'] ?? false;
        final String nombre = data?['nombre'] ?? _emailController.text.trim().split('@')[0];

        print('Usuario encontrado en Firestore - ID: $userId, Nombre: $nombre');
        
        await _guardarDatosUsuario(userId, nombre);

        if (haSeleccionado) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ClienteHomeScreen(
                  clienteId: userId,
                  clienteNombre: nombre,
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SeleccionarSucursalesScreen(
                  userId: userId,
                  email: _emailController.text.trim(),
                ),
              ),
            );
          }
        }
      } else {
        final String nombre = _emailController.text.trim().split('@')[0];
        print('Usuario NO encontrado en Firestore, creando nuevo...');
        
        await _firestore.collection('Usuarios').doc(userId).set({
          'nombre': nombre,
          'email': _emailController.text.trim(),
          'puntos_cinepolis': 0,
          'ha_seleccionado_sucursales': false,
          'fecha_registro': FieldValue.serverTimestamp(),
        });
        
        await _guardarDatosUsuario(userId, nombre);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SeleccionarSucursalesScreen(
                userId: userId,
                email: _emailController.text.trim(),
              ),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') {
        mensaje = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        mensaje = 'Contraseña incorrecta';
      } else if (e.code == 'invalid-email') {
        mensaje = 'Correo electrónico inválido';
      } else if (e.code == 'too-many-requests') {
        mensaje = 'Demasiados intentos. Intente más tarde';
      }
      _mostrarMensaje(mensaje, Colors.red);
    } catch (e) {
      _mostrarMensaje('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      backgroundColor: const Color(0xFF0D47A1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 45,
                        backgroundColor: Color(0xFF1976D2),
                        backgroundImage: NetworkImage(
                          'https://raw.githubusercontent.com/JazminAnaya/Imagenes-de-Figma-Cinepolis-Valtierra/refs/heads/main/Logo.png'
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Cinépolis Valtierra',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        color: const Color(0xFF0D47A1),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Correo Electrónico', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Ingrese su correo',
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.black45),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Ingrese su contraseña',
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.black45),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: Colors.black45,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
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
                                'Iniciar Sesión',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegistroScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0D47A1)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Crear Cuenta',
                          style: TextStyle(
                            color: Color(0xFF0D47A1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}