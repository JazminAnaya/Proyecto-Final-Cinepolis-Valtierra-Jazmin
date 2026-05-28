import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pelicula_model.dart';

class PeliculasDetailScreen extends StatelessWidget {
   final Pelicula pelicula;

  const PeliculasDetailScreen({super.key, required this.pelicula});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Ver Película',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                // Imagen y título
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen del poster
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: pelicula.imagen != null && pelicula.imagen!.isNotEmpty
                          ? Image.network(
                              pelicula.imagen!,
                              width: 120,
                              height: 160,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 120,
                                  height: 160,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                );
                              },
                            )
                          : Container(
                              width: 120,
                              height: 160,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.movie, size: 40, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pelicula.nombre,
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D47A1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getClasificacionColor(pelicula.clasificacion).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  pelicula.clasificacion,
                                  style: TextStyle(
                                    color: _getClasificacionColor(pelicula.clasificacion),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  pelicula.genero,
                                  style: const TextStyle(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30, thickness: 1),
                // Datos de la película
                _buildDetailRow('ID', pelicula.id ?? '---'),
                _buildDetailRow('Director', pelicula.director),
                _buildDetailRow('Duración', '${pelicula.duracionMin} minutos'),
                _buildDetailRow('Idioma', pelicula.idioma),
                const SizedBox(height: 16),
                const Text(
                  'Sinopsis:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    pelicula.sinopsis.isNotEmpty ? pelicula.sinopsis : 'Sin sinopsis registrada',
                    style: const TextStyle(fontSize: 14, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text('Regresar', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getClasificacionColor(String clasificacion) {
    switch (clasificacion) {
      case 'AA':
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'B-15':
        return Colors.orange;
      case 'C':
        return Colors.deepOrange;
      case 'PG-13':
        return Colors.purple;
      case 'R':
      case 'NC-17':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}