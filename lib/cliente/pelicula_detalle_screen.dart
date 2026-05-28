import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/pelicula_model.dart';
import 'perfil_screen.dart';

class PeliculaDetalleScreen extends StatelessWidget {
  final Pelicula pelicula;
  final String? clienteId;
  final String? clienteNombre;

  const PeliculaDetalleScreen({
    super.key,
    required this.pelicula,
    this.clienteId,
    this.clienteNombre,
  });

  // Generar calificación aleatoria de 1 a 5 estrellas
  double get _calificacionAleatoria => (1 + (DateTime.now().millisecondsSinceEpoch % 400) / 100).clamp(1.0, 5.0);
  
  Widget _buildStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = rating - fullStars >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    
    return Row(
      children: [
        ...List.generate(fullStars, (index) => const Icon(Icons.star, color: Colors.amber, size: 20)),
        if (hasHalfStar) const Icon(Icons.star_half, color: Colors.amber, size: 20),
        ...List.generate(emptyStars, (index) => const Icon(Icons.star_border, color: Colors.amber, size: 20)),
        const SizedBox(width: 8),
        Text(
          '${rating.toStringAsFixed(1)}/5',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double rating = _calificacionAleatoria;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1), // Fondo azul
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
                  Text(
                    '¡Bienvenid@!',
                    style: GoogleFonts.roboto(fontSize: 12, color: Colors.white70),
                  ),
                  Text(
                    clienteNombre ?? 'Cliente',
                    style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent, // AppBar transparente
        elevation: 0,
        actions: [
          // Botón de perfil - CORREGIDO
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PerfilScreen(
                    clienteId: clienteId,
                    clienteNombre: clienteNombre ?? 'Cliente',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la película (más pequeña y centrada)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 200,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: pelicula.imagen != null && pelicula.imagen!.isNotEmpty
                        ? Image.network(
                            pelicula.imagen!,
                            width: 200,
                            height: 280,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white.withValues(alpha: 0.1),
                                child: const Center(
                                  child: Icon(Icons.broken_image, size: 50, color: Colors.white54),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.white.withValues(alpha: 0.1),
                            child: const Center(
                              child: Icon(Icons.movie, size: 50, color: Colors.white54),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            
            // Contenido
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    pelicula.nombre,
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // Calificación en estrellas (centrada)
                  Center(
                    child: _buildStars(rating),
                  ),
                  const SizedBox(height: 16),
                  
                  // Etiquetas (clasificación, duración, año)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          pelicula.clasificacion,
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${pelicula.duracionMin} min',
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Tarjeta de información (fondo semi-transparente)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.person, 'Director', pelicula.director),
                        const Divider(height: 20, thickness: 0.5, color: Colors.white24),
                        _buildInfoRow(Icons.category, 'Género', pelicula.genero),
                        const Divider(height: 20, thickness: 0.5, color: Colors.white24),
                        _buildInfoRow(Icons.language, 'Idioma', pelicula.idioma),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Sinopsis
                  const Text(
                    'Sinopsis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      pelicula.sinopsis.isNotEmpty 
                          ? pelicula.sinopsis 
                          : 'No hay sinopsis disponible para esta película.',
                      style: const TextStyle(
                        fontSize: 14, 
                        height: 1.6, 
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(width: 12),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}