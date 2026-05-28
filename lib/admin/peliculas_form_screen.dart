import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/pelicula_model.dart';

class PeliculasFormScreen extends StatefulWidget {
  final Pelicula? pelicula;

  const PeliculasFormScreen({super.key, this.pelicula});

  @override
  State<PeliculasFormScreen> createState() => _PeliculasFormScreenState();
}

class _PeliculasFormScreenState extends State<PeliculasFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  late TextEditingController _nombreController;
  late TextEditingController _directorController;
  late TextEditingController _duracionController;
  late TextEditingController _sinopsisController;
  late TextEditingController _imagenUrlController;  // ← NUEVO
  
  String _clasificacionSeleccionada = 'A';
  String _generoSeleccionado = 'Acción';
  String _idiomaSeleccionado = 'Español';
  
  String? _imagenPreview;  // Para vista previa de la imagen

  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _clasificaciones = [
    'AA', 'A', 'B', 'B-15', 'C', 'PG-13', 'R', 'NC-17'
  ];

  final List<String> _generos = [
    'Acción', 'Aventura', 'Ciencia Ficción', 'Comedia', 'Drama', 
    'Terror', 'Romance', 'Animación', 'Suspenso', 'Documental'
  ];

  final List<String> _idiomas = [
    'Español', 'Inglés', 'Subtitulada', 'Doblada', 'Idioma Original'
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.pelicula != null;
    _nombreController = TextEditingController(text: widget.pelicula?.nombre ?? '');
    _directorController = TextEditingController(text: widget.pelicula?.director ?? '');
    _duracionController = TextEditingController(text: widget.pelicula?.duracionMin.toString() ?? '');
    _sinopsisController = TextEditingController(text: widget.pelicula?.sinopsis ?? '');
    _imagenUrlController = TextEditingController(text: widget.pelicula?.imagen ?? '');
    _clasificacionSeleccionada = widget.pelicula?.clasificacion ?? 'A';
    _generoSeleccionado = widget.pelicula?.genero ?? 'Acción';
    _idiomaSeleccionado = widget.pelicula?.idioma ?? 'Español';
    _imagenPreview = widget.pelicula?.imagen;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _directorController.dispose();
    _duracionController.dispose();
    _sinopsisController.dispose();
    _imagenUrlController.dispose();
    super.dispose();
  }

  void _actualizarPreview(String url) {
    setState(() {
      _imagenPreview = url;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final pelicula = Pelicula(
      id: widget.pelicula?.id,
      nombre: _nombreController.text.trim(),
      clasificacion: _clasificacionSeleccionada,
      director: _directorController.text.trim(),
      duracionMin: int.tryParse(_duracionController.text) ?? 0,
      genero: _generoSeleccionado,
      idioma: _idiomaSeleccionado,
      sinopsis: _sinopsisController.text.trim(),
      imagen: _imagenUrlController.text.trim(),
    );

    bool success;
    if (_isEditing) {
      success = await _firebaseService.updatePelicula(pelicula);
    } else {
      final id = await _firebaseService.createPelicula(pelicula);
      success = id != null;
    }

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Película actualizada' : 'Película creada'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Película' : 'Nueva Película',
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_isEditing)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.movie, color: Color(0xFF0D47A1)),
                    const SizedBox(width: 10),
                    Text(
                      'ID: ${widget.pelicula!.id}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            _buildTextField(_nombreController, 'Nombre de la Película', Icons.movie, true),
            const SizedBox(height: 16),
            _buildTextField(_directorController, 'Director', Icons.person, true),
            const SizedBox(height: 16),
            _buildTextField(_duracionController, 'Duración (minutos)', Icons.timer, true, TextInputType.number),
            const SizedBox(height: 16),
            _buildGeneroDropdown(),
            const SizedBox(height: 16),
            _buildClasificacionDropdown(),
            const SizedBox(height: 16),
            _buildIdiomaDropdown(),
            const SizedBox(height: 16),
            _buildImagenUrlField(),  // ← NUEVO CAMPO
            const SizedBox(height: 16),
            _buildSinopsisField(),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      bool required, [TextInputType? keyboardType]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
        ),
      ),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es requerido';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildImagenUrlField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _imagenUrlController,
          decoration: InputDecoration(
            labelText: 'URL de la Imagen (poster)',
            hintText: 'https://ejemplo.com/imagen.jpg',
            prefixIcon: const Icon(Icons.image, color: Color(0xFF0D47A1)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.preview, color: Color(0xFF0D47A1)),
              onPressed: () => _actualizarPreview(_imagenUrlController.text),
              tooltip: 'Vista previa',
            ),
          ),
        ),
        if (_imagenPreview != null && _imagenPreview!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _imagenPreview!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Error al cargar la imagen'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGeneroDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _generoSeleccionado,
      decoration: InputDecoration(
        labelText: 'Género',
        prefixIcon: const Icon(Icons.category, color: Color(0xFF0D47A1)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
        ),
      ),
      items: _generos.map((String genero) {
        return DropdownMenuItem<String>(
          value: genero,
          child: Text(genero),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _generoSeleccionado = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Seleccione un género';
        }
        return null;
      },
    );
  }

  Widget _buildClasificacionDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _clasificacionSeleccionada,
      decoration: InputDecoration(
        labelText: 'Clasificación',
        prefixIcon: const Icon(Icons.verified, color: Color(0xFF0D47A1)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
        ),
      ),
      items: _clasificaciones.map((String clasificacion) {
        return DropdownMenuItem<String>(
          value: clasificacion,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _getClasificacionColor(clasificacion),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  clasificacion,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(_getClasificacionDescripcion(clasificacion)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _clasificacionSeleccionada = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Seleccione una clasificación';
        }
        return null;
      },
    );
  }

  Widget _buildIdiomaDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _idiomaSeleccionado,
      decoration: InputDecoration(
        labelText: 'Idioma',
        prefixIcon: const Icon(Icons.language, color: Color(0xFF0D47A1)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
        ),
      ),
      items: _idiomas.map((String idioma) {
        return DropdownMenuItem<String>(
          value: idioma,
          child: Text(idioma),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _idiomaSeleccionado = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Seleccione un idioma';
        }
        return null;
      },
    );
  }

  Widget _buildSinopsisField() {
    return TextFormField(
      controller: _sinopsisController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Sinopsis',
        prefixIcon: const Icon(Icons.description, color: Color(0xFF0D47A1)),
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'La sinopsis es requerida';
        }
        if (value.length < 10) {
          return 'La sinopsis debe tener al menos 10 caracteres';
        }
        return null;
      },
    );
  }

  Color _getClasificacionColor(String clasificacion) {
    switch (clasificacion) {
      case 'AA':
        return Colors.green;
      case 'A':
        return Colors.lightGreen;
      case 'B':
        return Colors.blue;
      case 'B-15':
        return Colors.orange;
      case 'C':
        return Colors.deepOrange;
      case 'PG-13':
        return Colors.purple;
      case 'R':
        return Colors.red;
      case 'NC-17':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  String _getClasificacionDescripcion(String clasificacion) {
    switch (clasificacion) {
      case 'AA':
        return 'Todo público';
      case 'A':
        return 'Para niños';
      case 'B':
        return 'Adolescentes';
      case 'B-15':
        return 'Mayores de 15 años';
      case 'C':
        return 'Adultos';
      case 'PG-13':
        return 'Padres guía';
      case 'R':
        return 'Restringido';
      case 'NC-17':
        return 'Solo adultos';
      default:
        return '';
    }
  }
}