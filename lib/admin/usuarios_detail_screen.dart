import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/usuario_model.dart';

class UsuariosDetailScreen extends StatelessWidget {
  final Usuario usuario;

  const UsuariosDetailScreen({super.key, required this.usuario});

  String _getNivelPorPuntos(int puntos) {
    if (puntos >= 500) return 'Platinum';
    if (puntos >= 200) return 'Gold';
    if (puntos >= 50) return 'Silver';
    return 'Fan';
  }

  Color _getNivelColor(String nivel) {
    switch (nivel) {
      case 'Platinum': return Colors.blueGrey;
      case 'Gold': return Colors.amber;
      case 'Silver': return Colors.grey;
      default: return Colors.brown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nivel = _getNivelPorPuntos(usuario.puntosCinepolis);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Ver Usuario',
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
                // Avatar y nombre
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            usuario.nombre,
                            style: GoogleFonts.roboto(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D47A1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getNivelColor(nivel).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              nivel,
                              style: TextStyle(
                                color: _getNivelColor(nivel),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30, thickness: 1),
                // Datos del usuario
                _buildDetailRow('ID', usuario.id ?? '---'),
                _buildDetailRow('Email', usuario.email),
                _buildDetailRow('Teléfono', usuario.telefono ?? 'No registrado'),
                _buildDetailRow('Ciudad', usuario.ciudad ?? 'No registrada'),
                _buildDetailRow('País', usuario.pais ?? 'No registrado'),
                _buildDetailRow('Fecha de Nacimiento', usuario.fechaNacimiento ?? 'No registrada'),
                _buildDetailRow('Puntos Cinépolis', '${usuario.puntosCinepolis} puntos'),
                _buildProgressBar(),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
            width: 140,
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

  Widget _buildProgressBar() {
    int puntos = usuario.puntosCinepolis;
    int puntosSiguienteNivel = 0;
    String siguienteNivel = '';
    
    if (puntos < 50) {
      puntosSiguienteNivel = 50;
      siguienteNivel = 'Silver';
    } else if (puntos < 200) {
      puntosSiguienteNivel = 200;
      siguienteNivel = 'Gold';
    } else if (puntos < 500) {
      puntosSiguienteNivel = 500;
      siguienteNivel = 'Platinum';
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.blueGrey),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Felicidades! Has alcanzado el nivel máximo Platinum',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }
    
    double progreso = puntos / puntosSiguienteNivel;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progreso a $siguienteNivel',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '$puntos / $puntosSiguienteNivel puntos',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progreso,
                minHeight: 10,
                backgroundColor: Colors.grey.shade300,
                color: _getNivelColor(siguienteNivel),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Faltan ${puntosSiguienteNivel - puntos} puntos para llegar a $siguienteNivel',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}