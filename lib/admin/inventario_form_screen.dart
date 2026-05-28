import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/inventario_model.dart';

class InventarioFormScreen extends StatefulWidget {
  final Inventario? producto;

  const InventarioFormScreen({super.key, this.producto});

  @override
  State<InventarioFormScreen> createState() => _InventarioFormScreenState();
}

class _InventarioFormScreenState extends State<InventarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _imagenController;
  
  String _categoriaSeleccionada = 'Alimentos';
  String _estadoSeleccionado = 'Disponible';

  bool _isLoading = false;
  bool _isEditing = false;
  bool _mostrarVistaPrevia = false;

  final List<String> _categorias = ['Alimentos', 'Bebidas', 'Dulces'];
  final List<String> _estados = ['Disponible', 'Poco Stock', 'Agotado', 'Descontinuado'];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.producto != null;
    _nombreController = TextEditingController(text: widget.producto?.nombre ?? '');
    _precioController = TextEditingController(text: widget.producto?.precio.toString() ?? '');
    _stockController = TextEditingController(text: widget.producto?.stockDisponible.toString() ?? '');
    _imagenController = TextEditingController(text: widget.producto?.imagen ?? '');
    _categoriaSeleccionada = widget.producto?.categoria ?? 'Alimentos';
    _estadoSeleccionado = widget.producto?.estado ?? 'Disponible';
    
    if (_imagenController.text.isNotEmpty) {
      _mostrarVistaPrevia = true;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _imagenController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final producto = Inventario(
      id: widget.producto?.id,
      nombre: _nombreController.text.trim(),
      categoria: _categoriaSeleccionada,
      precio: double.tryParse(_precioController.text) ?? 0,
      stockDisponible: int.tryParse(_stockController.text) ?? 0,
      estado: _estadoSeleccionado,
      imagen: _imagenController.text.trim(),
    );

    bool success;
    if (_isEditing) {
      success = await _firebaseService.updateInventario(producto);
    } else {
      final id = await _firebaseService.createInventario(producto);
      success = id != null;
    }

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Producto actualizado' : 'Producto creado'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Producto' : 'Nuevo Producto', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_isEditing)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.inventory, color: Color(0xFF0D47A1)),
                    const SizedBox(width: 10),
                    Text('ID: ${widget.producto!.id}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            _buildTextField(_nombreController, 'Nombre del Producto', Icons.inventory, true),
            const SizedBox(height: 16),
            _buildCategoriaDropdown(),
            const SizedBox(height: 16),
            _buildTextField(_precioController, 'Precio', Icons.attach_money, true, TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(_stockController, 'Stock Disponible', Icons.store, true, TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(_imagenController, 'URL de la Imagen', Icons.image, false, TextInputType.url),
            const SizedBox(height: 8),
            // Vista previa de la imagen
            if (_mostrarVistaPrevia && _imagenController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vista previa:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _imagenController.text,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _buildEstadoDropdown(),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
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
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                        : const Text('Listo', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool required, [TextInputType? keyboardType]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (value) {
        if (label == 'URL de la Imagen') {
          setState(() {
            _mostrarVistaPrevia = value.isNotEmpty;
          });
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2)),
      ),
      validator: required ? (value) => value == null || value.isEmpty ? 'Este campo es requerido' : null : null,
    );
  }

  Widget _buildCategoriaDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _categoriaSeleccionada,
      decoration: InputDecoration(
        labelText: 'Categoría',
        prefixIcon: const Icon(Icons.category, color: Color(0xFF0D47A1)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2)),
      ),
      items: _categorias.map((String categoria) {
        IconData icon;
        switch (categoria) {
          case 'Alimentos': icon = Icons.fastfood; break;
          case 'Bebidas': icon = Icons.local_drink; break;
          case 'Dulces': icon = Icons.cake; break;
          default: icon = Icons.category;
        }
        return DropdownMenuItem<String>(
          value: categoria,
          child: Row(children: [Icon(icon, color: const Color(0xFF0D47A1), size: 20), const SizedBox(width: 8), Text(categoria)]),
        );
      }).toList(),
      onChanged: (value) => setState(() => _categoriaSeleccionada = value!),
      validator: (value) => value == null || value.isEmpty ? 'Seleccione una categoría' : null,
    );
  }

  Widget _buildEstadoDropdown() {
    String? dropdownValue = _estadoSeleccionado;
    if (!_estados.contains(dropdownValue)) {
      dropdownValue = _estados.first;
      _estadoSeleccionado = dropdownValue;
    }
    
    return DropdownButtonFormField<String>(
      initialValue: dropdownValue,
      decoration: InputDecoration(
        labelText: 'Estado',
        prefixIcon: const Icon(Icons.circle, color: Color(0xFF0D47A1)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2)),
      ),
      items: _estados.map((String estado) {
        Color color;
        switch (estado) {
          case 'Disponible': color = Colors.green; break;
          case 'Poco Stock': color = Colors.orange; break;
          case 'Agotado': color = Colors.red; break;
          case 'Descontinuado': color = Colors.grey; break;
          default: color = Colors.grey;
        }
        return DropdownMenuItem<String>(
          value: estado,
          child: Row(children: [Icon(Icons.circle, color: color, size: 16), const SizedBox(width: 8), Text(estado)]),
        );
      }).toList(),
      onChanged: (value) => setState(() => _estadoSeleccionado = value!),
      validator: (value) => value == null || value.isEmpty ? 'Seleccione un estado' : null,
    );
  }
}