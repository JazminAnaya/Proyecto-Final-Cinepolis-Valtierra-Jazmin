import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/admin/pedidos_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'empleados_screen.dart';
import 'complejos_screen.dart';
import 'salas_screen.dart';
import 'peliculas_screen.dart';
import 'funciones_screen.dart';
import 'inventario_screen.dart';
import 'usuarios_screen.dart';
import '../main.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Tablas disponibles
  final List<Map<String, dynamic>> _tables = [
    {'title': 'Empleados', 'icon': Icons.people, 'color': const Color(0xFF0D47A1), 'description': 'Gestionar personal del cine'},
    {'title': 'Sucursales', 'icon': Icons.location_city, 'color': const Color(0xFF1976D2), 'description': 'Administrar ubicaciones'},
    {'title': 'Salas', 'icon': Icons.theaters, 'color': const Color(0xFF2196F3), 'description': 'Configurar salas de cine'},
    {'title': 'Peliculas', 'icon': Icons.movie, 'color': const Color(0xFF42A5F5), 'description': 'Gestionar cartelera'},
    {'title': 'Funciones', 'icon': Icons.schedule, 'color': const Color(0xFF1565C0), 'description': 'Horarios y programacion de peliculas'},
    {'title': 'Inventario', 'icon': Icons.inventory, 'color': const Color(0xFF64B5F6), 'description': 'Control de productos'},
    {'title': 'Usuarios', 'icon': Icons.people_outline, 'color': const Color(0xFF90CAF9), 'description': 'Base de usuarios'},
    {'title': 'Pedidos', 'icon': Icons.receipt, 'color': const Color(0xFF0D47A1), 'description': 'Gestionar pedidos de clientes'}, // ← NUEVO
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _cerrarSesion() async {
    // Limpiar SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('adminEmail');
    await prefs.remove('adminLoggedIn');
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  void _confirmarCerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar Sesión'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header con imagen circular y botones
            _buildHeader(),
            // Grid de tablas
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _tables.length,
                      itemBuilder: (context, index) {
                        return _buildTableCard(_tables[index], index);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D47A1),
            Color(0xFF1976D2),
            Color(0xFF2196F3),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen circular (Logo de Cinepolis)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                'https://raw.githubusercontent.com/JazminAnaya/Imagenes-de-Figma-Cinepolis-Valtierra/refs/heads/main/Logo.png'
              ),
              onBackgroundImageError: (_, __) {
                print('Error al cargar el logo');
              },
            ),
          ),
          const SizedBox(width: 15),
          // Texto del header
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menú',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Administra todas las tablas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Botón de información
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                _showInfoDialog();
              },
              icon: const Icon(
                Icons.info_outline,
                color: Color(0xFF0D47A1),
              ),
              tooltip: 'Información',
            ),
          ),
          const SizedBox(width: 8),
          // Botón de cerrar sesión - NUEVO
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                _confirmarCerrarSesion();
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              tooltip: 'Cerrar Sesión',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(Map<String, dynamic> table, int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      builder: (context, double value, Widget? child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            _handleTableTap(table['title']);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (table['color'] as Color).withValues(alpha: 0.1),
                  (table['color'] as Color).withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (table['color'] as Color).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      table['icon'] as IconData,
                      size: 40,
                      color: table['color'] as Color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    table['title'] as String,
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D47A1),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    table['description'] as String,
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTableTap(String tableName) {
    switch (tableName) {
      case 'Empleados':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const EmpleadosScreen()));
        break;
      case 'Sucursales':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ComplejosScreen()));
        break;
      case 'Salas':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SalasScreen()));
        break;
      case 'Peliculas':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PeliculasScreen()));
        break;
      case 'Funciones':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const FuncionesScreen()));
        break;
      case 'Inventario':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const InventarioScreen()));
        break;
      case 'Usuarios':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const UsuariosScreen()));
        break;
        case 'Pedidos':  // ← NUEVO
      Navigator.push(context, MaterialPageRoute(builder: (context) => const PedidosScreen()));
      break;
      default:
        _showTableDialog(tableName, 'Proximamente');
    }
  }

  void _showTableDialog(String tableName, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.data_usage, size: 60, color: Color(0xFF0D47A1)),
              ),
              const SizedBox(height: 20),
              Text('Tabla: $tableName', style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1))),
              const SizedBox(height: 15),
              Text(message, style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[700])),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Entendido', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info, color: Color(0xFF0D47A1)),
            const SizedBox(width: 10),
            Text('Información del Sistema', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 Tablas disponibles:', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            const Text('✓ Empleados (CRUD completo)'),
            const Text('✓ Sucursales (CRUD completo)'),
            const Text('✓ Salas (CRUD completo)'),
            const Text('✓ Peliculas (CRUD completo)'),
            const Text('✓ Funciones (CRUD completo)'),
            const Text('✓ Inventario (CRUD completo)'),
            const Text('✓ Usuarios (CRUD completo)'),
            const SizedBox(height: 15),
            Text('✨ Funcionalidades:', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            const Text('• CRUD completo conectado a Firebase'),
            const Text('• Busqueda avanzada'),
            const Text('• Reportes en tiempo real'),
            const Text('• Sincronizacion con Firestore'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Color(0xFF0D47A1))),
          ),
        ],
      ),
    );
  }
}