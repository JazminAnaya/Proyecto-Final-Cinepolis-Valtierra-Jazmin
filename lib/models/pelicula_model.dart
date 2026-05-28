class Pelicula {
  String? id;
  String nombre;
  String clasificacion;
  String director;
  int duracionMin;
  String genero;
  String idioma;
  String sinopsis;
  String? imagen;  // ← AGREGAR ESTE CAMPO

  Pelicula({
    this.id,
    required this.nombre,
    required this.clasificacion,
    required this.director,
    required this.duracionMin,
    required this.genero,
    required this.idioma,
    required this.sinopsis,
    this.imagen,  // ← AGREGAR ESTE PARÁMETRO
  });

  // Convertir de Firestore a objeto
  factory Pelicula.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Pelicula(
      id: documentId,
      nombre: data['nombre']?.toString() ?? '',
      clasificacion: data['clasificacion']?.toString() ?? 'A',
      director: data['director']?.toString() ?? '',
      duracionMin: (data['duracion_min'] ?? 0).toInt(),
      genero: data['genero']?.toString() ?? 'Acción',
      idioma: data['idioma']?.toString() ?? 'Español',
      sinopsis: data['sinopsis']?.toString() ?? '',
      imagen: data['imagen']?.toString(),  // ← AGREGAR ESTA LÍNEA
    );
  }

  // Convertir a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'clasificacion': clasificacion,
      'director': director,
      'duracion_min': duracionMin,
      'genero': genero,
      'idioma': idioma,
      'sinopsis': sinopsis,
      'imagen': imagen,  // ← AGREGAR ESTA LÍNEA
    };
  }

  // Copiar con cambios
  Pelicula copyWith({
    String? id,
    String? nombre,
    String? clasificacion,
    String? director,
    int? duracionMin,
    String? genero,
    String? idioma,
    String? sinopsis,
    String? imagen,
  }) {
    return Pelicula(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      clasificacion: clasificacion ?? this.clasificacion,
      director: director ?? this.director,
      duracionMin: duracionMin ?? this.duracionMin,
      genero: genero ?? this.genero,
      idioma: idioma ?? this.idioma,
      sinopsis: sinopsis ?? this.sinopsis,
      imagen: imagen ?? this.imagen,
    );
  }
}