import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/carrito_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'cliente_home_screen.dart';
import 'perfil_screen.dart';

class TipoBoletosScreen extends StatefulWidget {
  final int asientosSeleccionados;
  final String peliculaNombre;
  final String salaNombre;
  final String horario;
  final String? clienteId;
  final String? clienteNombre;
  final List<String> asientos;

  const TipoBoletosScreen({
    super.key,
    required this.asientosSeleccionados,
    required this.peliculaNombre,
    required this.salaNombre,
    required this.horario,
    this.clienteId,
    this.clienteNombre,
    required this.asientos,
  });

  @override
  State<TipoBoletosScreen> createState() => _TipoBoletosScreenState();
}

class _TipoBoletosScreenState extends State<TipoBoletosScreen> {
  int _adultos = 0;
  int _ninos = 0;
  int _terceraEdad = 0;

  final int _precioAdulto = 75;
  final int _precioNino = 60;
  final int _precioTerceraEdad = 65;

  int get _totalSeleccionados => _adultos + _ninos + _terceraEdad;
  int get _totalPrecio => (_adultos * _precioAdulto) + (_ninos * _precioNino) + (_terceraEdad * _precioTerceraEdad);
  bool get _isCompleto => _totalSeleccionados == widget.asientosSeleccionados;

  void _incrementar(String tipo) {
    if (_totalSeleccionados >= widget.asientosSeleccionados) return;
    setState(() {
      switch (tipo) {
        case 'adulto':
          _adultos++;
          break;
        case 'nino':
          _ninos++;
          break;
        case 'terceraEdad':
          _terceraEdad++;
          break;
      }
    });
  }

  void _decrementar(String tipo) {
    setState(() {
      switch (tipo) {
        case 'adulto':
          if (_adultos > 0) _adultos--;
          break;
        case 'nino':
          if (_ninos > 0) _ninos--;
          break;
        case 'terceraEdad':
          if (_terceraEdad > 0) _terceraEdad--;
          break;
      }
    });
  }

  Future<void> _guardarEnCarrito() async {
    List<CarritoItem> items = [];
    if (_adultos > 0) {
      items.add(CarritoItem(
        tipo: 'Adulto',
        cantidad: _adultos,
        precio: _precioAdulto,
        subtotal: _adultos * _precioAdulto,
      ));
    }
    if (_ninos > 0) {
      items.add(CarritoItem(
        tipo: 'Niño',
        cantidad: _ninos,
        precio: _precioNino,
        subtotal: _ninos * _precioNino,
      ));
    }
    if (_terceraEdad > 0) {
      items.add(CarritoItem(
        tipo: '3ra Edad',
        cantidad: _terceraEdad,
        precio: _precioTerceraEdad,
        subtotal: _terceraEdad * _precioTerceraEdad,
      ));
    }

    final carritoBoletos = CarritoBoletos(
      peliculaNombre: widget.peliculaNombre,
      salaNombre: widget.salaNombre,
      horario: widget.horario,
      asientos: widget.asientos,
      items: items,
      total: _totalPrecio,
    );

    final prefs = await SharedPreferences.getInstance();
    List<String> carritoExistente = prefs.getStringList('carrito') ?? [];
    carritoExistente.add(jsonEncode(carritoBoletos.toMap()));
    await prefs.setStringList('carrito', carritoExistente);
  }

  void _mostrarDialogConfirmacion() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.confirmation_number, color: Color(0xFF0D47A1), size: 28),
            const SizedBox(width: 10),
            const Text('Confirmar compra', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Datos de la función
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🎬 ${widget.peliculaNombre}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('🏷️ ${widget.salaNombre} - ${widget.horario}', style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('🪑 Asientos: ${widget.asientos.join(", ")}', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Boletos seleccionados:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_adultos > 0) Text('• Adulto: $_adultos x \$$_precioAdulto = \$${_adultos * _precioAdulto}'),
              if (_ninos > 0) Text('• Niño: $_ninos x \$$_precioNino = \$${_ninos * _precioNino}'),
              if (_terceraEdad > 0) Text('• 3ra Edad: $_terceraEdad x \$$_precioTerceraEdad = \$${_terceraEdad * _precioTerceraEdad}'),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('\$$_totalPrecio', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D47A1))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _guardarEnCarrito();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Boletos agregados al carrito!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => ClienteHomeScreen(
                    clienteId: widget.clienteId,
                    clienteNombre: widget.clienteNombre,
                  ),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _onListo() {
    if (!_isCompleto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debes seleccionar ${widget.asientosSeleccionados} boletos ($_totalSeleccionados seleccionados)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    _mostrarDialogConfirmacion();
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
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.local_movies, color: Color(0xFF0D47A1), size: 20),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¡Bienvenid@!', style: GoogleFonts.roboto(fontSize: 12, color: Colors.white70)),
                  Text(widget.clienteNombre ?? 'Cliente', style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        actions: [
          // Botón de perfil
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerfilScreen(
          clienteId: widget.clienteId,
          clienteNombre: widget.clienteNombre ?? 'Cliente',
        ),
      ),
    );
  },
  child: Container(
    margin: const EdgeInsets.only(right: 16),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Image.network(
        'https://raw.githubusercontent.com/JazminAnaya/Imagenes-de-Figma-Cinepolis-Valtierra/refs/heads/main/perfil.jpeg',
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(Icons.person, color: Color(0xFF0D47A1), size: 25),
          );
        },
      ),
    ),
  ),
),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Text(widget.peliculaNombre, style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1))),
                const SizedBox(height: 4),
                Text('${widget.salaNombre} - ${widget.horario}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF0D47A1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('${widget.asientosSeleccionados} asientos: ${widget.asientos.join(", ")}', style: const TextStyle(fontSize: 12, color: Color(0xFF0D47A1))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Tipo de boletos', style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1))),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('$_totalSeleccionados de ${widget.asientosSeleccionados} boletos', style: TextStyle(fontSize: 14, color: _isCompleto ? Colors.green : Colors.grey)),
          ),
          const SizedBox(height: 20),
          _buildTipoBoletoCard(icon: Icons.person, titulo: 'Adulto', precio: _precioAdulto, cantidad: _adultos, onIncrement: () => _incrementar('adulto'), onDecrement: () => _decrementar('adulto')),
          _buildTipoBoletoCard(icon: Icons.child_care, titulo: 'Niño', precio: _precioNino, cantidad: _ninos, onIncrement: () => _incrementar('nino'), onDecrement: () => _decrementar('nino')),
          _buildTipoBoletoCard(icon: Icons.elderly, titulo: '3ra edad', precio: _precioTerceraEdad, cantidad: _terceraEdad, onIncrement: () => _incrementar('terceraEdad'), onDecrement: () => _decrementar('terceraEdad')),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2))]),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text('\$$_totalPrecio', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)))]),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _onListo, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Continuar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipoBoletoCard({required IconData icon, required String titulo, required int precio, required int cantidad, required VoidCallback onIncrement, required VoidCallback onDecrement}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFF0D47A1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(25)), child: Icon(icon, size: 28, color: const Color(0xFF0D47A1))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text('\$$precio', style: const TextStyle(fontSize: 14, color: Colors.grey))])),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(25)),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.remove, size: 20), onPressed: onDecrement, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
                SizedBox(width: 30, child: Text('$cantidad', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(Icons.add, size: 20), onPressed: onIncrement, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}