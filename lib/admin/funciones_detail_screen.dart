import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/funcion_model.dart';

class FuncionesDetailScreen extends StatelessWidget {
  final Funcion funcion;
  const FuncionesDetailScreen({super.key, required this.funcion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Ver Función', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white)),
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
                Row(children: [
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0D47A1).withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.schedule, size: 50, color: Color(0xFF0D47A1))),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(funcion.nombrePelicula.isNotEmpty ? funcion.nombrePelicula : 'Cargando...', style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1))),
                    const SizedBox(height: 4),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: getEstadoColor(funcion.estado).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Text(funcion.estado, style: TextStyle(color: getEstadoColor(funcion.estado), fontWeight: FontWeight.w500, fontSize: 12))),
                  ])),
                ]),
                const Divider(height: 30, thickness: 1),
                _buildDetailRow('ID', funcion.id ?? '---'),
                _buildDetailRow('Película', funcion.nombrePelicula.isNotEmpty ? funcion.nombrePelicula : 'No disponible'),
                _buildDetailRow('Sala', funcion.nombreSala.isNotEmpty ? funcion.nombreSala : 'No disponible'),
                _buildDetailRow('Sucursal', funcion.nombreComplejo.isNotEmpty ? funcion.nombreComplejo : 'No disponible'),
                _buildDetailRow('Formato', funcion.formato),
                _buildDetailRow('Fecha y Hora', funcion.fechaFormateada),
                _buildDetailRow('Precio Base', '\$${funcion.precioBase.toStringAsFixed(2)}'),
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
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
    ]));
  }
}