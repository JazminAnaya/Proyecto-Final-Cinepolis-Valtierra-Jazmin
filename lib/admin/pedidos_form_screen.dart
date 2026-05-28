import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/pedido_model.dart';
import '../models/usuario_model.dart';
import '../models/inventario_model.dart';
import '../models/pelicula_model.dart';
import '../models/funcion_model.dart';

class PedidosFormScreen extends StatefulWidget {
  final Pedido? pedido;

  const PedidosFormScreen({super.key, this.pedido});

  @override
  State<PedidosFormScreen> createState() => _PedidosFormScreenState();
}

class _PedidosFormScreenState extends State<PedidosFormScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isEditing = false;
  
  // Datos del pedido
  String _clienteId = '';
  String _clienteNombre = '';
  String _metodoPago = 'efectivo';
  String _estado = 'pagado';
  
  // Items del pedido
  List<Map<String, dynamic>> _boletos = [];
  List<Map<String, dynamic>> _alimentos = [];
  
  // Controladores
  final TextEditingController _clienteNombreController = TextEditingController();
  final TextEditingController _clienteIdController = TextEditingController();
  
  // Listas para dropdowns
  List<Usuario> _usuarios = [];
  List<Pelicula> _peliculas = [];
  List<Funcion> _funciones = [];
  List<Inventario> _productos = [];
  
  // Variables para agregar boletos
  String? _selectedPeliculaId;
  String? _selectedFuncionId;
  String? _selectedSalaNombre;
  String? _selectedHorario;
  final List<String> _selectedAsientos = [];
  final TextEditingController _asientoController = TextEditingController();
  
  // Variables para agregar alimentos
  String? _selectedProductoId;
  int _cantidadProducto = 1;
  
  @override
  void initState() {
    super.initState();
    _isEditing = widget.pedido != null;
    
    if (_isEditing) {
      _cargarDatosPedido();
    }
    _cargarListas();
  }
  
  void _cargarDatosPedido() {
    final pedido = widget.pedido!;
    _clienteId = pedido.clienteId;
    _clienteNombre = pedido.clienteNombre;
    _metodoPago = pedido.metodoPago;
    _estado = pedido.estado;
    _boletos = List<Map<String, dynamic>>.from(pedido.boletos);
    _alimentos = List<Map<String, dynamic>>.from(pedido.alimentos);
    
    _clienteNombreController.text = _clienteNombre;
    _clienteIdController.text = _clienteId;
  }
  
  Future<void> _cargarListas() async {
    setState(() => _isLoading = true);
    
    // Cargar usuarios
    _firebaseService.getUsuarios().listen((usuarios) {
      if (mounted) setState(() => _usuarios = usuarios);
    });
    
    // Cargar películas
    _firebaseService.getPeliculas().listen((peliculas) {
      if (mounted) setState(() => _peliculas = peliculas);
    });
    
    // Cargar productos
    _firebaseService.getInventario().listen((productos) {
      if (mounted) setState(() => _productos = productos);
    });
    
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
  }
  
  Future<void> _cargarFuncionesPorPelicula(String peliculaId) async {
    _firebaseService.getFuncionesByPelicula(peliculaId).listen((funciones) {
      if (mounted) setState(() => _funciones = funciones);
    });
  }
  
  void _agregarBoleto() {
    if (_selectedPeliculaId == null) {
      _mostrarMensaje('Seleccione una película', Colors.red);
      return;
    }
    if (_selectedFuncionId == null) {
      _mostrarMensaje('Seleccione una función', Colors.red);
      return;
    }
    if (_selectedAsientos.isEmpty) {
      _mostrarMensaje('Agregue al menos un asiento', Colors.red);
      return;
    }
    
    final pelicula = _peliculas.firstWhere((p) => p.id == _selectedPeliculaId);
    final funcion = _funciones.firstWhere((f) => f.id == _selectedFuncionId);
    final totalBoletos = _selectedAsientos.length * 75;
    
    _boletos.add({
      'peliculaNombre': pelicula.nombre,
      'salaNombre': _selectedSalaNombre ?? funcion.nombreSala,
      'horario': _selectedHorario ?? '${funcion.fechaHora.hour}:${funcion.fechaHora.minute.toString().padLeft(2, '0')}',
      'asientos': List<String>.from(_selectedAsientos),
      'cantidadBoletos': _selectedAsientos.length,
      'total': totalBoletos,
    });
    
    _selectedPeliculaId = null;
    _selectedFuncionId = null;
    _selectedSalaNombre = null;
    _selectedHorario = null;
    _selectedAsientos.clear();
    _asientoController.clear();
    
    setState(() {});
    _mostrarMensaje('Boleto agregado', Colors.green);
  }
  
  void _eliminarBoleto(int index) {
    setState(() {
      _boletos.removeAt(index);
    });
    _mostrarMensaje('Boleto eliminado', Colors.orange);
  }
  
  void _agregarAlimento() {
    if (_selectedProductoId == null) {
      _mostrarMensaje('Seleccione un producto', Colors.red);
      return;
    }
    
    final producto = _productos.firstWhere((p) => p.id == _selectedProductoId);
    final total = producto.precio * _cantidadProducto;
    
    _alimentos.add({
      'nombre': producto.nombre,
      'categoria': producto.categoria,
      'cantidad': _cantidadProducto,
      'precio': producto.precio,
      'total': total,
    });
    
    _selectedProductoId = null;
    _cantidadProducto = 1;
    
    setState(() {});
    _mostrarMensaje('Producto agregado', Colors.green);
  }
  
  void _eliminarAlimento(int index) {
    setState(() {
      _alimentos.removeAt(index);
    });
    _mostrarMensaje('Producto eliminado', Colors.orange);
  }
  
  void _agregarAsiento() {
    if (_asientoController.text.trim().isEmpty) {
      _mostrarMensaje('Ingrese un asiento (ej: A1)', Colors.red);
      return;
    }
    
    final asiento = _asientoController.text.trim().toUpperCase();
    if (_selectedAsientos.contains(asiento)) {
      _mostrarMensaje('El asiento ya está agregado', Colors.orange);
      return;
    }
    
    setState(() {
      _selectedAsientos.add(asiento);
      _asientoController.clear();
    });
  }
  
  void _eliminarAsiento(String asiento) {
    setState(() {
      _selectedAsientos.remove(asiento);
    });
  }
  
  double get _totalGeneral {
    double total = 0;
    for (var boleto in _boletos) {
      total += (boleto['total'] ?? 0).toDouble();
    }
    for (var alimento in _alimentos) {
      total += (alimento['total'] ?? 0).toDouble();
    }
    return total;
  }
  
  Future<void> _guardarPedido() async {
    if (_clienteId.isEmpty) {
      _mostrarMensaje('Seleccione un cliente', Colors.red);
      return;
    }
    if (_boletos.isEmpty && _alimentos.isEmpty) {
      _mostrarMensaje('Agregue al menos un boleto o alimento', Colors.red);
      return;
    }
    
    setState(() => _isLoading = true);
    
    final pedido = Pedido(
      id: widget.pedido?.id,
      clienteId: _clienteId,
      clienteNombre: _clienteNombre,
      boletos: _boletos,
      alimentos: _alimentos,
      total: _totalGeneral,
      metodoPago: _metodoPago,
      fecha: widget.pedido?.fecha ?? DateTime.now(),
      estado: _estado,
    );
    
    bool success;
    if (_isEditing) {
      success = await _firebaseService.updatePedido(pedido);
    } else {
      final id = await _firebaseService.createPedido(pedido);
      success = id != null;
    }
    
    setState(() => _isLoading = false);
    
    if (success) {
      _mostrarMensaje(_isEditing ? 'Pedido actualizado' : 'Pedido creado', Colors.green);
      Navigator.pop(context, true);
    } else {
      _mostrarMensaje('Error al guardar', Colors.red);
    }
  }
  
  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: color),
    );
  }
  
  void _seleccionarCliente(Usuario? usuario) {
    if (usuario != null) {
      setState(() {
        _clienteId = usuario.id!;
        _clienteNombre = usuario.nombre;
        _clienteNombreController.text = usuario.nombre;
        _clienteIdController.text = usuario.id!;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Pedido' : 'Nuevo Pedido',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _confirmarEliminacion(),
              tooltip: 'Eliminar Pedido',
            ),
        ],
      ),
      body: _isLoading && _usuarios.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selección de Cliente
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información del Cliente',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<Usuario>(
                              decoration: InputDecoration(
                                labelText: 'Seleccionar Cliente',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: _usuarios.map((usuario) {
                                return DropdownMenuItem(
                                  value: usuario,
                                  child: Text('${usuario.nombre} - ${usuario.email}'),
                                );
                              }).toList(),
                              onChanged: _seleccionarCliente,
                              initialValue: _usuarios.firstWhere(
                                (u) => u.id == _clienteId,
                                orElse: () => _usuarios.isNotEmpty ? _usuarios.first : Usuario(
                                  id: '',
                                  nombre: '',
                                  email: '',
                                  puntosCinepolis: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _clienteNombreController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Nombre del Cliente',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Boletos
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🎬 Boletos',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                            ),
                            const SizedBox(height: 12),
                            
                            if (_boletos.isNotEmpty) ...[
                              const Text('Boletos agregados:'),
                              const SizedBox(height: 8),
                              ..._boletos.asMap().entries.map((entry) {
                                final index = entry.key;
                                final boleto = entry.value;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${boleto['peliculaNombre']} - ${boleto['horario']}',
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              'Asientos: ${(boleto['asientos'] as List).join(", ")}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              'Total: \$${boleto['total']}',
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF0D47A1)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () => _eliminarBoleto(index),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const Divider(),
                              const SizedBox(height: 8),
                            ],
                            
                            const Text('Agregar nuevo boleto:', style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Película',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: _peliculas.map((p) {
                                return DropdownMenuItem(
                                  value: p.id,
                                  child: Text(p.nombre),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPeliculaId = value;
                                  _selectedFuncionId = null;
                                  if (value != null) {
                                    _cargarFuncionesPorPelicula(value);
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Función (Horario)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: _funciones.map((f) {
                                final hora = '${f.fechaHora.hour}:${f.fechaHora.minute.toString().padLeft(2, '0')}';
                                return DropdownMenuItem(
                                  value: f.id,
                                  child: Text('${f.nombreSala} - $hora'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                final funcion = _funciones.firstWhere((f) => f.id == value);
                                setState(() {
                                  _selectedFuncionId = value;
                                  _selectedSalaNombre = funcion.nombreSala;
                                  _selectedHorario = '${funcion.fechaHora.hour}:${funcion.fechaHora.minute.toString().padLeft(2, '0')}';
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _asientoController,
                                    decoration: InputDecoration(
                                      labelText: 'Asiento (ej: A1)',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _agregarAsiento,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D47A1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('+', style: TextStyle(fontSize: 20)),
                                ),
                              ],
                            ),
                            
                            if (_selectedAsientos.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: _selectedAsientos.map((asiento) => Chip(
                                  label: Text(asiento),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () => _eliminarAsiento(asiento),
                                )).toList(),
                              ),
                            ],
                            
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _agregarBoleto,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D47A1).withValues(alpha: 0.2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Agregar Boleto', style: TextStyle(color: Color(0xFF0D47A1))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Alimentos
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🍿 Alimentos',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                            ),
                            const SizedBox(height: 12),
                            
                            if (_alimentos.isNotEmpty) ...[
                              const Text('Productos agregados:'),
                              const SizedBox(height: 8),
                              ..._alimentos.asMap().entries.map((entry) {
                                final index = entry.key;
                                final alimento = entry.value;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${alimento['nombre']} x${alimento['cantidad']}',
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              'Categoría: ${alimento['categoria']}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              'Total: \$${alimento['total']}',
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF0D47A1)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () => _eliminarAlimento(index),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const Divider(),
                              const SizedBox(height: 8),
                            ],
                            
                            const Text('Agregar nuevo producto:', style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Producto',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: _productos.map((p) {
                                return DropdownMenuItem(
                                  value: p.id,
                                  child: Text('${p.nombre} - \$${p.precio}'),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedProductoId = value),
                            ),
                            const SizedBox(height: 12),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: '1',
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Cantidad',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    onChanged: (value) {
                                      _cantidadProducto = int.tryParse(value) ?? 1;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _agregarAlimento,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0D47A1),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Agregar', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Método de pago y estado
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información del Pago',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Método de Pago',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    initialValue: _metodoPago,
                                    items: const [
                                      DropdownMenuItem(value: 'efectivo', child: Text('Efectivo')),
                                      DropdownMenuItem(value: 'tarjeta', child: Text('Tarjeta')),
                                    ],
                                    onChanged: (value) => setState(() => _metodoPago = value!),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Estado',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    initialValue: _estado,
                                    items: const [
                                      DropdownMenuItem(value: 'pagado', child: Text('Pagado')),
                                      DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                                      DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
                                    ],
                                    onChanged: (value) => setState(() => _estado = value!),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Total
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL DEL PEDIDO:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${_totalGeneral.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: Color(0xFF0D47A1)),
                            ),
                            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF0D47A1))),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _guardarPedido,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D47A1),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
      );
  }
  
  void _confirmarEliminacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Pedido'),
        content: const Text('¿Estás seguro de que deseas eliminar este pedido? Esta acción no se puede deshacer.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final success = await _firebaseService.deletePedido(widget.pedido!.id!);
              setState(() => _isLoading = false);
              if (success && mounted) {
                _mostrarMensaje('Pedido eliminado correctamente', Colors.green);
                Navigator.pop(context, true);
              } else {
                _mostrarMensaje('Error al eliminar pedido', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}