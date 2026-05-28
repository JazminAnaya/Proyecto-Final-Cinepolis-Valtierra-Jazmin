import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/cliente/cliente_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/firebase_service.dart';
import '../models/pedido_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PagoScreen extends StatefulWidget {
  final String? clienteId;
  final String? clienteNombre;

  const PagoScreen({super.key, this.clienteId, this.clienteNombre});

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _metodoPago = 'efectivo';
  bool _isLoading = true;
  bool _isProcessing = false;
  List<dynamic> _items = [];
  
  final TextEditingController _titularController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  
  final _formKeyTarjeta = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
  }

  @override
  void dispose() {
    _titularController.dispose();
    _numeroController.dispose();
    _fechaController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _cargarCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> carrito = prefs.getStringList('carrito') ?? [];
    setState(() {
      _items = carrito.map((item) => jsonDecode(item)).toList();
      _isLoading = false;
    });
  }

  double get _totalGeneral {
    double total = 0;
    for (var item in _items) {
      final totalItem = item['total'];
      if (totalItem != null) {
        total += totalItem.toDouble();
      }
    }
    return total;
  }

  List<Map<String, dynamic>> get _boletosItems {
    return _items
        .where((item) => item['tipo'] == 'boletos')
        .map((item) => {
              'peliculaNombre': item['peliculaNombre'] ?? '',
              'salaNombre': item['salaNombre'] ?? '',
              'horario': item['horario'] ?? '',
              'asientos': List<String>.from(item['asientos'] ?? []),
              'cantidadBoletos': item['cantidadBoletos'] ?? 0,
              'total': item['total'] ?? 0,
            })
        .toList();
  }

  List<Map<String, dynamic>> get _alimentosItems {
    return _items
        .where((item) => item['tipo'] == 'alimento')
        .map((item) => {
              'nombre': item['nombre'] ?? '',
              'categoria': item['categoria'] ?? '',
              'cantidad': item['cantidad'] ?? 0,
              'precio': item['precio'] ?? 0,
              'total': item['total'] ?? 0,
            })
        .toList();
  }

  Future<String?> _getRealClienteId() async {
    if (widget.clienteId != null &&
        widget.clienteId!.isNotEmpty &&
        widget.clienteId != 'anonimo') {
      print('Usando widget.clienteId: ${widget.clienteId}');
      return widget.clienteId;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedClienteId = prefs.getString('clienteId');

    if (savedClienteId != null &&
        savedClienteId.isNotEmpty &&
        savedClienteId != 'anonimo') {
      print('Usando savedClienteId: $savedClienteId');
      return savedClienteId;
    }

    if (widget.clienteNombre != null && widget.clienteNombre!.isNotEmpty) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Usuarios')
            .where('nombre', isEqualTo: widget.clienteNombre)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userId = querySnapshot.docs.first.id;
          await prefs.setString('clienteId', userId);
          print('Cliente encontrado por nombre: $userId');
          return userId;
        }
      } catch (e) {
        print('Error buscando usuario: $e');
      }
    }

    print('NO se encontró clienteId');
    return '';
  }

  // Método para obtener el ID del producto por su nombre
  Future<String?> _obtenerProductoIdPorNombre(String nombreProducto) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Inventario_Alimentos')
          .where('nombre', isEqualTo: nombreProducto)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Error buscando producto por nombre: $e');
      return null;
    }
  }

  Future<void> _procesarPago() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos en el carrito'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_metodoPago == 'tarjeta') {
      if (!_formKeyTarjeta.currentState!.validate()) {
        return;
      }
    }

    setState(() => _isProcessing = true);

    final realClienteId = await _getRealClienteId();
    final clienteIdFinal = realClienteId ?? '';
    if (clienteIdFinal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró el cliente'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isProcessing = false);
      return;
    }
    
    final clienteNombreFinal = widget.clienteNombre ?? 'Cliente';
    
    print('=== GUARDANDO PEDIDO ===');
    print('clienteIdFinal: $clienteIdFinal');
    print('clienteNombreFinal: $clienteNombreFinal');
    print('Total: $_totalGeneral');

    final pedido = Pedido(
      clienteId: clienteIdFinal,
      clienteNombre: clienteNombreFinal,
      boletos: _boletosItems,
      alimentos: _alimentosItems,
      total: _totalGeneral,
      metodoPago: _metodoPago,
      fecha: DateTime.now(),
      estado: 'pagado',
    );

    if (_metodoPago == 'tarjeta') {
      pedido.datosTarjeta = {
        'titular': _titularController.text,
        'numeroOculto': '**** **** **** ${_numeroController.text.substring(_numeroController.text.length - 4)}',
        'fechaVencimiento': _fechaController.text,
        'cvv': '***',
      };
    }

    final pedidoId = await _firebaseService.createPedido(pedido);

    // ===== DISMINUIR STOCK DE ALIMENTOS =====
    if (_alimentosItems.isNotEmpty) {
      print('=== ACTUALIZANDO STOCK ===');
      
      for (var alimento in _alimentosItems) {
        final productoId = await _obtenerProductoIdPorNombre(alimento['nombre']);
        
        if (productoId != null) {
          final cantidadComprada = alimento['cantidad'] ?? 1;
          final success = await _firebaseService.actualizarStockAlimento(productoId, cantidadComprada);
          
          if (success) {
            print('✅ Stock actualizado: ${alimento['nombre']} - Cantidad: $cantidadComprada');
          } else {
            print('❌ Error actualizando stock para: ${alimento['nombre']}');
          }
        } else {
          print('❌ No se encontró ID para producto: ${alimento['nombre']}');
        }
      }
    }

    // ===== AGREGAR PUNTOS CINÉPOLIS =====
    int puntosGanados = (_totalGeneral / 10).floor();
    await _firebaseService.agregarPuntosCliente(
      clienteId: clienteIdFinal,
      puntosAgregar: puntosGanados,
    );
    print('Puntos ganados: $puntosGanados');

    print('Pedido guardado con ID: $pedidoId');

    setState(() => _isProcessing = false);

    if (pedidoId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('carrito');
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('¡Pago exitoso!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Número de pedido: ${pedidoId.substring(0, 6)}...', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                const Text('Tu pedido ha sido registrado correctamente'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClienteHomeScreen(
                        clienteId: clienteIdFinal,
                        clienteNombre: clienteNombreFinal,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al procesar el pago'), backgroundColor: Colors.red),
      );
    }
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
        title: Text('Pagar', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('Carrito vacío', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('No hay productos para pagar', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Resumen del pedido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const Divider(),
                              if (_boletosItems.isNotEmpty) ...[
                                const Text('Boletos:', style: TextStyle(fontWeight: FontWeight.w500)),
                                ..._boletosItems.map((b) => Padding(
                                  padding: const EdgeInsets.only(left: 8, top: 4),
                                  child: Text('• ${b['peliculaNombre']} - ${(b['asientos'] as List).join(", ")}: \$${b['total']}'),
                                )),
                                const SizedBox(height: 8),
                              ],
                              if (_alimentosItems.isNotEmpty) ...[
                                const Text('Alimentos:', style: TextStyle(fontWeight: FontWeight.w500)),
                                ..._alimentosItems.map((a) => Padding(
                                  padding: const EdgeInsets.only(left: 8, top: 4),
                                  child: Text('• ${a['nombre']} x${a['cantidad']}: \$${a['total']}'),
                                )),
                              ],
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text('\$${_totalGeneral.toStringAsFixed(2)}', 
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Método de pago', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMetodoPagoOption('efectivo', 'Efectivo', Icons.money),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildMetodoPagoOption('tarjeta', 'Tarjeta', Icons.credit_card),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              if (_metodoPago == 'tarjeta')
                                Form(
                                  key: _formKeyTarjeta,
                                  child: Column(
                                    children: [
                                      _buildTarjetaTextField(
                                        _titularController,
                                        'Nombre del titular',
                                        Icons.person,
                                        TextInputType.text,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildTarjetaTextField(
                                        _numeroController,
                                        'Número de tarjeta',
                                        Icons.credit_card,
                                        TextInputType.number,
                                        isObscure: false,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildTarjetaTextField(
                                              _fechaController,
                                              'MM/AA',
                                              Icons.calendar_today,
                                              TextInputType.datetime,
                                              isObscure: false,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildTarjetaTextField(
                                              _cvvController,
                                              'CVV',
                                              Icons.security,
                                              TextInputType.number,
                                              isObscure: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _procesarPago,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isProcessing
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                              : const Text('Pagar ahora', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMetodoPagoOption(String value, String label, IconData icon) {
    return GestureDetector(
      onTap: () => setState(() => _metodoPago = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _metodoPago == value ? const Color(0xFF0D47A1).withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _metodoPago == value ? const Color(0xFF0D47A1) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _metodoPago == value ? const Color(0xFF0D47A1) : Colors.grey),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: _metodoPago == value ? const Color(0xFF0D47A1) : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaTextField(
    TextEditingController controller, 
    String label, 
    IconData icon,
    TextInputType keyboardType, {
    bool isObscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es requerido';
        }
        if (label == 'Número de tarjeta' && value.length < 16) {
          return 'Ingrese 16 dígitos';
        }
        if (label == 'CVV' && value.length < 3) {
          return 'CVV inválido';
        }
        if (label == 'MM/AA' && value.length < 5) {
          return 'Formato MM/AA';
        }
        return null;
      },
    );
  }
}