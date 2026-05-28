import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/inventario_model.dart';

class InventarioDetailScreen extends StatelessWidget {
  final Inventario producto;

  const InventarioDetailScreen({super.key, required this.producto});

  IconData _getCategoriaIcon(String categoria) {
    switch (categoria) {
      case 'Alimentos': return Icons.fastfood;
      case 'Bebidas': return Icons.local_drink;
      case 'Dulces': return Icons.cake;
      default: return Icons.inventory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Ver Producto', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen y nombre
                Row(
                  children: [
                    // Imagen del producto
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: producto.imagen.isNotEmpty
                          ? Image.network(
                              producto.imagen,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(_getCategoriaIcon(producto.categoria), size: 45, color: const Color(0xFF0D47A1)),
                                );
                              },
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(_getCategoriaIcon(producto.categoria), size: 45, color: const Color(0xFF0D47A1)),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(producto.nombre, style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1)), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: getInventarioEstadoColor(producto.estado).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                            child: Text(producto.estado, style: TextStyle(color: getInventarioEstadoColor(producto.estado), fontWeight: FontWeight.w500, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1),
                const SizedBox(height: 16),
                // Datos del producto
                _buildDetailRow('ID', producto.id ?? '---'),
                _buildDetailRow('Categoría', producto.categoria),
                _buildDetailRow('Precio', '\$${producto.precio.toStringAsFixed(2)}'),
                _buildDetailRow('Stock Disponible', '${producto.stockDisponible} unidades'),
                _buildStockStatus(),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text('Regresar', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildStockStatus() {
    String status;
    Color color;
    IconData icon;
    String mensaje;
    
    if (producto.stockDisponible <= 0) {
      status = 'Agotado';
      color = Colors.red;
      icon = Icons.warning_amber_rounded;
      mensaje = 'Este producto está agotado. Se recomienda reabastecer pronto.';
    } else if (producto.stockDisponible < 10) {
      status = 'Stock Bajo';
      color = Colors.orange;
      icon = Icons.warning;
      mensaje = 'El stock es bajo (menos de 10 unidades). Se recomienda reabastecer.';
    } else {
      status = 'Stock Suficiente';
      color = Colors.green;
      icon = Icons.check_circle;
      mensaje = 'El stock es suficiente para la demanda actual.';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(status, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(mensaje, style: TextStyle(color: color, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}