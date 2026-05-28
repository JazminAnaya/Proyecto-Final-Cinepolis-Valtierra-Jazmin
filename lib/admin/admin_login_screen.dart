import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_dashboard.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final String _correctUser = "adminCineV";
  final String _correctPassword = "admin180623";

  void _showCredentialsHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF1976D2)),
            SizedBox(width: 10),
            Text('Credenciales del Sistema', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Utiliza los siguientes datos para realizar pruebas de desarrollo:', style: TextStyle(color: Colors.black54, fontSize: 14)),
            SizedBox(height: 15),
            Row(
              children: [
                Text('Usuario: ', style: TextStyle(fontWeight: FontWeight.bold)),
                SelectableText('adminCineV', style: TextStyle(color: Color(0xFF0D47A1), fontFamily: 'monospace')),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text('Contraseña: ', style: TextStyle(fontWeight: FontWeight.bold)),
                SelectableText('admin180623', style: TextStyle(color: Color(0xFF0D47A1), fontFamily: 'monospace')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Color(0xFF0D47A1))),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bluePrimary = Color(0xFF0D47A1);
    const Color blueSecondary = Color(0xFF1976D2);

    return Scaffold(
      backgroundColor: bluePrimary,
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
                        color: bluePrimary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 45,
                        backgroundColor: blueSecondary,
                        backgroundImage: NetworkImage(
                          'https://raw.githubusercontent.com/JazminAnaya/Imagenes-de-Figma-Cinepolis-Valtierra/refs/heads/main/Logo.png'
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '¡Bienvenido al\nmodo administrativo!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        color: bluePrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Por favor ingrese el usuario y contraseña para continuar',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Usuario', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
                          IconButton(
                            icon: const Icon(Icons.help_outline, color: blueSecondary, size: 20),
                            onPressed: _showCredentialsHelp,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _userController,
                      decoration: InputDecoration(
                        hintText: 'Ingrese su usuario',
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.black45),
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
                        onPressed: _isLoading ? null : () async {
                          String userInput = _userController.text.trim();
                          String passwordInput = _passwordController.text.trim();

                          if (userInput == _correctUser && passwordInput == _correctPassword) {
                            setState(() {
                              _isLoading = true;
                            });
                            
                            // Mostrar diálogo de agradecimiento
                            await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_circle_outline,
                                          size: 60,
                                          color: Color(0xFF0D47A1),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        '¡Gracias por confirmar tus datos!',
                                        style: GoogleFonts.roboto(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0D47A1),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        'Ahora puedes modificar las tablas:\nempleados, sucursales, salas, películas, funciones, inventario, usuarios y pedidos',
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 25),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () => Navigator.pop(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF0D47A1),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                          ),
                                          child: const Text(
                                            'Continuar',
                                            style: TextStyle(
                                              color: Colors.white,
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
                            );
                            
                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminDashboard(),
                                ),
                              );
                            }
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red),
                                    SizedBox(width: 10),
                                    Text('Error de ingreso'),
                                  ],
                                ),
                                content: const Text('El usuario o la contraseña son incorrectos. Por favor, verifícalos e intenta de nuevo.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Entendido', style: TextStyle(color: Color(0xFF0D47A1))),
                                  )
                                ],
                              ),
                            );
                          }
                        },
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
                                'Ingresar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
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