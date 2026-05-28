import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilScreen extends StatefulWidget {
  final String? clienteId;
  final String? clienteNombre;

  const PerfilScreen({super.key, this.clienteId, this.clienteNombre});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    setState(() => _isLoading = true);
    
    String? userId = widget.clienteId;
    
    // Si no hay ID en widget, buscar en SharedPreferences
    if (userId == null || userId.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('clienteId');
    }
    
    if (userId == null || userId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error cargando perfil: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cerrarSesion() async {
    // Limpiar SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('clienteId');
    await prefs.remove('clienteNombre');
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  String _formatearFecha(String? fechaString) {
    if (fechaString == null) return 'No registrada';
    try {
      final fecha = DateTime.parse(fechaString);
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    } catch (e) {
      return fechaString;
    }
  }

  String _getMembresia(int puntos) {
    if (puntos >= 500) return 'Platinum';
    if (puntos >= 200) return 'Gold';
    if (puntos >= 50) return 'Silver';
    return 'Fan';
  }

  // Obtener lista de sucursales preferidas del usuario
  List<String> _getSucursalesPreferidas() {
    final sucursales = _userData?['sucursales_preferidas_nombres'];
    if (sucursales is List) {
      return List<String>.from(sucursales);
    }
    return [];
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
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.local_movies, color: Color(0xFF0D47A1), size: 20),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Mi cuenta',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('No se pudieron cargar los datos', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarDatosUsuario,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                        child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Tarjeta de perfil con foto
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            // Foto de perfil
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                  'https://raw.githubusercontent.com/JazminAnaya/Imagenes-de-Figma-Cinepolis-Valtierra/refs/heads/main/perfil.jpeg',
                                ),
                                onBackgroundImageError: (_, __) {},
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _userData?['nombre'] ?? 'Usuario',
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getMembresia(_userData?['puntos_cinepolis'] ?? 0),
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                      
                      // Información del usuario
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tarjeta de puntos
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.star, color: Color(0xFF0D47A1), size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Puntos Cinépolis', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                        Text(
                                          '${_userData?['puntos_cinepolis'] ?? 0} pts',
                                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('Canjear', style: TextStyle(color: Color(0xFF0D47A1), fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            const Text('Información personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            
                            // Nombre
                            _buildInfoRow(Icons.person_outline, 'Nombre', _userData?['nombre'] ?? 'No registrado'),
                            const SizedBox(height: 16),
                            
                            // Email
                            _buildInfoRow(Icons.email_outlined, 'Correo electrónico', _userData?['email'] ?? 'No registrado'),
                            const SizedBox(height: 16),
                            
                            // Teléfono
                            _buildInfoRow(Icons.phone_outlined, 'Teléfono', _userData?['telefono'] ?? 'No registrado'),
                            const SizedBox(height: 16),
                            
                            // Fecha de nacimiento
                            _buildInfoRow(Icons.cake_outlined, 'Fecha de nacimiento', _formatearFecha(_userData?['fecha_nacimiento'])),
                            const SizedBox(height: 16),
                            
                            // País
                            _buildInfoRow(Icons.public_outlined, 'País', _userData?['pais'] ?? 'No registrado'),
                            const SizedBox(height: 16),
                            
                            // Ciudad
                            _buildInfoRow(Icons.location_city_outlined, 'Ciudad', _userData?['ciudad'] ?? 'No registrado'),
                            
                            const SizedBox(height: 24),
                            
                            const Text('Sucursales preferidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            
                            // Sucursales preferidas - DINÁMICAS desde Firebase
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: _getSucursalesPreferidas().isEmpty
                                    ? [
                                        const Row(
                                          children: [
                                            Icon(Icons.info_outline, color: Colors.grey, size: 20),
                                            SizedBox(width: 12),
                                            Text('No hay sucursales seleccionadas', style: TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                      ]
                                    : _getSucursalesPreferidas().asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final sucursal = entry.value;
                                        return Column(
                                          children: [
                                            _buildSucursalItem(sucursal),
                                            if (index < _getSucursalesPreferidas().length - 1)
                                              const Divider(),
                                          ],
                                        );
                                      }).toList(),
                              ),
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Botón cerrar sesión
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      title: const Text('Cerrar sesión'),
                                      content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _cerrarSesion();
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF0D47A1), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSucursalItem(String nombre) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          color: Color(0xFF0D47A1),
          size: 22,
        ),
        const SizedBox(width: 12),
        Text(
          nombre,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}