import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/complejo_model.dart';
import 'success_screen.dart';

class SeleccionarSucursalesScreen extends StatefulWidget {
  final String userId;
  final String email;

  const SeleccionarSucursalesScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  State<SeleccionarSucursalesScreen> createState() => _SeleccionarSucursalesScreenState();
}

class _SeleccionarSucursalesScreenState extends State<SeleccionarSucursalesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Complejo> _sucursales = [];
  final List<Complejo> _sucursalesSeleccionadas = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  // Límite máximo de sucursales
  final int _maxSucursales = 3;

  @override
  void initState() {
    super.initState();
    _cargarSucursales();
  }

  Future<void> _cargarSucursales() async {
    try {
      final snapshot = await _firestore.collection('Complejos').get();
      final sucursales = snapshot.docs.map((doc) {
        final data = doc.data();
        return Complejo(
          id: doc.id,
          nombre: data['nombre'] ?? '',
          ciudad: data['ciudad'] ?? '',
          direccion: data['direccion'] ?? '',
          telefono: data['telefono'] ?? '',
          estado: data['estado'] ?? 'Activo',
        );
      }).toList();
      
      setState(() {
        _sucursales = sucursales;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar sucursales: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar sucursales: $e';
      });
    }
  }

  Future<void> _guardarSeleccion() async {
    // Validar que haya seleccionado al menos una sucursal
    if (_sucursalesSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una sucursal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Obtener los IDs y nombres de las sucursales seleccionadas
      final List<String> sucursalesIds = _sucursalesSeleccionadas.map((s) => s.id!).toList();
      final List<String> sucursalesNombres = _sucursalesSeleccionadas.map((s) => s.nombre).toList();
      
      print('📦 Guardando IDs: $sucursalesIds');
      print('📦 Guardando Nombres: $sucursalesNombres');
      
      // Usar la colección 'Usuarios' (con mayúscula como en tu Firebase)
      final docRef = _firestore.collection('Usuarios').doc(widget.userId);
      
      // Verificar si el documento existe
      final doc = await docRef.get();
      
      if (!doc.exists) {
        // Si no existe, crearlo con los dos campos
        await docRef.set({
          'nombre': widget.email.split('@')[0],
          'email': widget.email,
          'puntos_cinepolis': 0,
          'ha_seleccionado_sucursales': true,
          'fecha_registro': FieldValue.serverTimestamp(),
          'sucursales_preferidas': sucursalesIds,           // Guardar IDs
          'sucursales_preferidas_nombres': sucursalesNombres, // Guardar nombres
        });
        print('✅ Usuario creado con sucursales_preferidas y sucursales_preferidas_nombres');
      } else {
        // Si existe, actualizar ambos campos
        await docRef.update({
          'sucursales_preferidas': sucursalesIds,
          'sucursales_preferidas_nombres': sucursalesNombres,
          'ha_seleccionado_sucursales': true,
        });
        print('✅ Sucursales actualizadas');
      }

      if (mounted) {
        // Navegar a SuccessScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessScreen()),
        );
      }
    } catch (e) {
      print('❌ Error al guardar: $e');
      setState(() {
        _errorMessage = 'Error al guardar: $e';
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleSeleccion(Complejo sucursal) {
    setState(() {
      if (_sucursalesSeleccionadas.contains(sucursal)) {
        // Si ya está seleccionada, la quitamos
        _sucursalesSeleccionadas.remove(sucursal);
      } else {
        // Si no está seleccionada, verificamos el límite
        if (_sucursalesSeleccionadas.length >= _maxSucursales) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Solo puedes seleccionar hasta $_maxSucursales sucursales'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        _sucursalesSeleccionadas.add(sucursal);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Seleccionar Sucursales',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Indicador de límite
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF0D47A1)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Selecciona hasta $_maxSucursales sucursales de tu preferencia',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D47A1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_sucursalesSeleccionadas.length}/$_maxSucursales',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sucursales.length,
                    itemBuilder: (context, index) {
                      final sucursal = _sucursales[index];
                      final isSelected = _sucursalesSeleccionadas.contains(sucursal);
                      final isDisabled = !isSelected && _sucursalesSeleccionadas.length >= _maxSucursales;
                      
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: isSelected
                              ? const BorderSide(color: Color(0xFF0D47A1), width: 2)
                              : BorderSide.none,
                        ),
                        child: Opacity(
                          opacity: isDisabled ? 0.5 : 1.0,
                          child: CheckboxListTile(
                            title: Text(
                              sucursal.nombre,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? const Color(0xFF0D47A1) : Colors.black87,
                              ),
                            ),
                            subtitle: Text(sucursal.ciudad),
                            value: isSelected,
                            activeColor: const Color(0xFF0D47A1),
                            onChanged: isDisabled && !isSelected
                                ? null
                                : (_) => _toggleSeleccion(sucursal),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _guardarSeleccion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Continuar',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}