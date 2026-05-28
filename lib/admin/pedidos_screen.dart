import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/pedido_model.dart';
import 'pedidos_detail_screen.dart';
import 'pedidos_form_screen.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filtroEstado = 'Todos';
  bool _isLoading = true;
  List<Pedido> _pedidosCache = [];

  final List<String> _estados = ['Todos', 'pagado', 'pendiente', 'cancelado'];

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarPedidos() async {
    setState(() => _isLoading = true);
    _firebaseService.getPedidos().listen((pedidos) {
      if (mounted) {
        setState(() {
        _pedidosCache = pedidos;
        _isLoading = false;
      });
      }
    });
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'No disponible';
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  String _getResumenProductos(Pedido pedido) {
    List<String> items = [];
    
    for (var boleto in pedido.boletos) {
      items.add('🎬 ${boleto['peliculaNombre']}');
    }
    
    for (var i = 0; i < pedido.alimentos.length && i < 2; i++) {
      items.add('🍿 ${pedido.alimentos[i]['nombre']} x${pedido.alimentos[i]['cantidad']}');
    }
    
    if (pedido.alimentos.length > 2) {
      items.add('+${pedido.alimentos.length - 2} más');
    }
    
    if (items.isEmpty) return 'Sin productos';
    return items.join('\n');
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pagado':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _eliminarPedido(Pedido pedido) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Pedido'),
        content: Text('¿Deseas eliminar el pedido #${pedido.id!.substring(0, 6).toUpperCase()}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await _firebaseService.deletePedido(pedido.id!);
      setState(() => _isLoading = false);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido eliminado'), backgroundColor: Colors.green),
        );
        _cargarPedidos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Pedidos', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PedidosFormScreen()),
              );
              if (result == true) _cargarPedidos();
            },
            tooltip: 'Nuevo Pedido',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarPedidos,
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por cliente o ID...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0D47A1)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _estados.map((estado) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(estado == 'Todos' ? 'Todos' : 
                        estado == 'pagado' ? 'Pagado' :
                        estado == 'pendiente' ? 'Pendiente' : 'Cancelado'),
                    selected: _filtroEstado == estado,
                    onSelected: (selected) => setState(() => _filtroEstado = estado),
                    selectedColor: const Color(0xFF0D47A1).withValues(alpha: 0.2),
                  ),
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt, color: Color(0xFF0D47A1), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Total de pedidos: ${_pedidosCache.length}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildCards(),
          ),
        ],
      ),
    );
  }

  Widget _buildCards() {
    var filtrados = _pedidosCache;
    
    if (_searchQuery.isNotEmpty) {
      filtrados = filtrados.where((p) {
        return p.id!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               p.clienteNombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               p.clienteId.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    if (_filtroEstado != 'Todos') {
      filtrados = filtrados.where((p) => p.estado == _filtroEstado).toList();
    }
    
    if (filtrados.isEmpty) {
      return const Center(child: Text('No hay pedidos registrados'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtrados.length,
      itemBuilder: (context, index) {
        final pedido = filtrados[index];
        final fecha = _formatearFecha(pedido.fecha);
        final resumen = _getResumenProductos(pedido);
        final estadoColor = _getEstadoColor(pedido.estado);
        
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pedido #${pedido.id!.substring(0, 6).toUpperCase()}',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D47A1),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: estadoColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            pedido.estado == 'pagado' ? 'Pagado' :
                            pedido.estado == 'pendiente' ? 'Pendiente' : 'Cancelado',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: estadoColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          pedido.clienteNombre,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          fecha,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        resumen,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.payment, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              pedido.metodoPago == 'efectivo' ? 'Efectivo' : 'Tarjeta',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        Text(
                          '\$${pedido.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PedidosDetailScreen(pedido: pedido),
                        ),
                      ),
                      icon: const Icon(Icons.visibility, color: Color(0xFF1976D2), size: 20),
                      label: const Text('Ver', style: TextStyle(color: Color(0xFF1976D2))),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey.shade300),
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PedidosFormScreen(pedido: pedido),
                          ),
                        );
                        if (result == true) _cargarPedidos();
                      },
                      icon: const Icon(Icons.edit, color: Color(0xFFFFC107), size: 20),
                      label: const Text('Editar', style: TextStyle(color: Color(0xFFFFC107))),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey.shade300),
                    TextButton.icon(
                      onPressed: () => _eliminarPedido(pedido),
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}