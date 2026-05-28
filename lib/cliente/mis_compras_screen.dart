import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cliente_home_screen.dart';
import 'alimentos_screen.dart';
import 'carrito_screen.dart';
import 'perfil_screen.dart';

class MisComprasScreen extends StatefulWidget {
  final String? clienteId;
  final String? clienteNombre;

  const MisComprasScreen({super.key, this.clienteId, this.clienteNombre});

  @override
  State<MisComprasScreen> createState() => _MisComprasScreenState();
}

class _MisComprasScreenState extends State<MisComprasScreen> {
  List<QueryDocumentSnapshot> _pedidos = [];
  bool _isLoading = true;
  String _nombreCliente = '';

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    setState(() => _isLoading = true);
    
    // 1. Obtener el ID real del cliente desde SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('clienteId');
    
    print('=== DEBUG ===');
    print('widget.clienteId: ${widget.clienteId}');
    print('savedId de SharedPreferences: $savedId');
    
    // Usar el ID que tengamos disponible
    final idParaBuscar = savedId ?? widget.clienteId;
    
    print('ID que voy a usar para buscar: $idParaBuscar');
    final todosPedidos = await FirebaseFirestore.instance
    .collection('pedidos')
    .get();

    print('TOTAL pedidos en firebase: ${todosPedidos.docs.length}');
    
    if (idParaBuscar == null || idParaBuscar.isEmpty) {
      print('NO HAY ID - Mostrando carrito vacío');
      setState(() {
        _isLoading = false;
        _nombreCliente = widget.clienteNombre ?? 'Cliente';
      });
      return;
    }
    
    // 2. Buscar pedidos en Firebase
    try {
      final querySnapshot = await FirebaseFirestore.instance
        .collection('pedidos')
        .where('clienteId', isEqualTo: idParaBuscar)
        .get();
      
      print('Pedidos encontrados: ${querySnapshot.docs.length}');
      for (var doc in querySnapshot.docs) {
        print(doc.data());
}
      
      setState(() {
        _pedidos = querySnapshot.docs;
        _isLoading = false;
        _nombreCliente = widget.clienteNombre ?? 'Cliente';
      });
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatearFecha(Timestamp? fecha) {
    if (fecha == null) return 'Fecha no disponible';
    final date = fecha.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¡Bienvenid@!', style: GoogleFonts.roboto(fontSize: 12, color: Colors.white70)),
                  Text(_nombreCliente, style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarritoScreen(
                    clienteId: widget.clienteId,
                    clienteNombre: _nombreCliente,
                  ),
                ),
              );
            },
          ),
          // Botón de perfil
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerfilScreen(
          clienteId: widget.clienteId,
          clienteNombre: _nombreCliente,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pedidos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No tienes compras realizadas', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Realiza tu primera compra', style: TextStyle(color: Colors.grey[500])),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClienteHomeScreen(
                                clienteId: widget.clienteId,
                                clienteNombre: _nombreCliente,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Ir a la cartelera', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pedidos.length,
                  itemBuilder: (context, index) {
                    final doc = _pedidos[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final total = (data['total'] ?? 0).toDouble();
                    final metodoPago = data['metodoPago'] ?? 'efectivo';
                    final fecha = data['fecha'] as Timestamp?;
                    
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D47A1).withValues(alpha: 0.05),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pedido #${doc.id.substring(0, 6).toUpperCase()}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(_formatearFecha(fecha), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Pagado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                                ),
                              ],
                            ),
                          ),
                          Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      // ================= BOLETOS =================

      if (data['boletos'] != null)
        ...List<Map<String, dynamic>>.from(
          data['boletos'],
        ).map((boleto) {

          return Container(

            margin: const EdgeInsets.only(bottom: 12),

            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  boleto['peliculaNombre'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Sala: ${boleto['salaNombre']}',
                ),

                Text(
                  'Horario: ${boleto['horario']}',
                ),

                Text(
                  'Asientos: ${(boleto['asientos'] as List).join(", ")}',
                ),

                Text(
                  'Boletos: ${boleto['cantidadBoletos']}',
                ),

                const SizedBox(height: 6),

                Text(
                  'Subtotal: \$${boleto['total']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),

      // ================= ALIMENTOS =================

      if (data['alimentos'] != null)
        ...List<Map<String, dynamic>>.from(
          data['alimentos'],
        ).map((alimento) {

          return Container(

            margin: const EdgeInsets.only(bottom: 12),

            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  alimento['nombre'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Cantidad: ${alimento['cantidad']}',
                ),

                Text(
                  'Subtotal: \$${alimento['total']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),

      const Divider(),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Text(
            'Método: ${metodoPago == 'efectivo' ? 'Efectivo' : 'Tarjeta'}',

            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),

          Text(
            '\$${total.toStringAsFixed(2)}',

            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
        ],
      ),
    ],
  ),
),
                        ],
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Cartelera'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Alimentos'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Mis compras'),
        ],
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ClienteHomeScreen(
                  clienteId: widget.clienteId,
                  clienteNombre: _nombreCliente,
                ),
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AlimentosScreen(
                  clienteId: widget.clienteId,
                  clienteNombre: _nombreCliente,
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CarritoScreen(
                  clienteId: widget.clienteId,
                  clienteNombre: _nombreCliente,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}