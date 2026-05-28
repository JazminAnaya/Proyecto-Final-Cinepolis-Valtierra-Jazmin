import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/usuario_model.dart';
import '../models/empleado_model.dart';
import '../models/complejo_model.dart';
import '../models/sala_model.dart';
import '../models/pelicula_model.dart';
import '../models/funcion_model.dart';
import '../models/inventario_model.dart';
import '../models/pedido_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Colecciones
  final String _empleadosCollection = 'Empleados';
  final String _complejosCollection = 'Complejos';
  final String _salasCollection = 'Salas';
  final String _peliculasCollection = 'Peliculas';
  final String _funcionesCollection = 'Funciones';
  final String _inventarioCollection = 'Inventario_Alimentos';
  // ignore: unused_field
  final String _usuariosCollection = 'Usuarios';
  final String _pedidosCollection = 'pedidos'; // Nueva colección

  // ========== EMPLEADOS CRUD ==========
  
  Stream<List<Empleado>> getEmpleados() {
    try {
      return _firestore
          .collection(_empleadosCollection)
          .orderBy('nombre')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Empleado.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en getEmpleados: $e');
      return Stream.value([]);
    }
  }

  Future<Empleado?> getEmpleadoById(String id) async {
    try {
      if (id.isEmpty) return null;
      DocumentSnapshot doc = await _firestore.collection(_empleadosCollection).doc(id).get();
      if (doc.exists) {
        return Empleado.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error al obtener empleado: $e');
      return null;
    }
  }

  Future<String?> createEmpleado(Empleado empleado) async {
    try {
      DocumentReference docRef = await _firestore.collection(_empleadosCollection).add(empleado.toMap());
      print('Empleado creado: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error al crear empleado: $e');
      return null;
    }
  }

  Future<bool> updateEmpleado(Empleado empleado) async {
    try {
      if (empleado.id == null || empleado.id!.isEmpty) return false;
      await _firestore
          .collection(_empleadosCollection)
          .doc(empleado.id)
          .update(empleado.toMap());
      print('Empleado actualizado: ${empleado.id}');
      return true;
    } catch (e) {
      print('Error al actualizar empleado: $e');
      return false;
    }
  }

  Future<bool> deleteEmpleado(String id) async {
    try {
      if (id.isEmpty) return false;
      final docRef = _firestore.collection(_empleadosCollection).doc(id);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        print('Empleado no existe: $id');
        return false;
      }
      await docRef.delete();
      print('Empleado eliminado: $id');
      return true;
    } catch (e) {
      print('Error al eliminar empleado: $e');
      return false;
    }
  }

  Stream<List<Empleado>> searchEmpleados(String query) {
    try {
      if (query.isEmpty) return getEmpleados();
      return _firestore
          .collection(_empleadosCollection)
          .orderBy('nombre')
          .startAt([query]).endAt(['$query\uf8ff'])
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Empleado.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en searchEmpleados: $e');
      return Stream.value([]);
    }
  }

  // ========== COMPLEJOS (SUCURSALES) CRUD ==========
  
  Stream<List<Complejo>> getComplejos() {
    try {
      return _firestore
          .collection(_complejosCollection)
          .orderBy('nombre')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Complejo.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en getComplejos: $e');
      return Stream.value([]);
    }
  }

  Future<Complejo?> getComplejoById(String id) async {
    try {
      if (id.isEmpty) return null;
      DocumentSnapshot doc = await _firestore.collection(_complejosCollection).doc(id).get();
      if (doc.exists) {
        return Complejo.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error al obtener complejo: $e');
      return null;
    }
  }

  Future<String?> createComplejo(Complejo complejo) async {
    try {
      DocumentReference docRef = await _firestore.collection(_complejosCollection).add(complejo.toMap());
      print('Complejo creado: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error al crear complejo: $e');
      return null;
    }
  }

  Future<bool> updateComplejo(Complejo complejo) async {
    try {
      if (complejo.id == null || complejo.id!.isEmpty) return false;
      await _firestore
          .collection(_complejosCollection)
          .doc(complejo.id)
          .update(complejo.toMap());
      print('Complejo actualizado: ${complejo.id}');
      return true;
    } catch (e) {
      print('Error al actualizar complejo: $e');
      return false;
    }
  }

  Future<bool> deleteComplejo(String id) async {
    try {
      if (id.isEmpty) return false;
      final docRef = _firestore.collection(_complejosCollection).doc(id);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        print('Complejo no existe: $id');
        return false;
      }
      await docRef.delete();
      print('Complejo eliminado: $id');
      return true;
    } catch (e) {
      print('Error al eliminar complejo: $e');
      return false;
    }
  }

  Stream<List<Complejo>> searchComplejos(String query) {
    try {
      if (query.isEmpty) return getComplejos();
      return _firestore
          .collection(_complejosCollection)
          .orderBy('nombre')
          .startAt([query]).endAt(['$query\uf8ff'])
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Complejo.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en searchComplejos: $e');
      return Stream.value([]);
    }
  }

  // ========== SALAS CRUD ==========
  
  Stream<List<Sala>> getSalas() {
    try {
      return _firestore
          .collection(_salasCollection)
          .orderBy('nombre')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Sala.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en getSalas: $e');
      return Stream.value([]);
    }
  }

  Future<Sala?> getSalaById(String id) async {
    try {
      if (id.isEmpty) return null;
      DocumentSnapshot doc = await _firestore.collection(_salasCollection).doc(id).get();
      if (doc.exists) {
        return Sala.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error al obtener sala: $e');
      return null;
    }
  }

  Future<String?> createSala(Sala sala) async {
    try {
      DocumentReference docRef = await _firestore.collection(_salasCollection).add(sala.toMap());
      print('Sala creada: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error al crear sala: $e');
      return null;
    }
  }

  Future<bool> updateSala(Sala sala) async {
    try {
      if (sala.id == null || sala.id!.isEmpty) return false;
      await _firestore
          .collection(_salasCollection)
          .doc(sala.id)
          .update(sala.toMap());
      print('Sala actualizada: ${sala.id}');
      return true;
    } catch (e) {
      print('Error al actualizar sala: $e');
      return false;
    }
  }

  Future<bool> deleteSala(String id) async {
    try {
      if (id.isEmpty) return false;
      final docRef = _firestore.collection(_salasCollection).doc(id);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        print('Sala no existe: $id');
        return false;
      }
      await docRef.delete();
      print('Sala eliminada: $id');
      return true;
    } catch (e) {
      print('Error al eliminar sala: $e');
      return false;
    }
  }

  Stream<List<Sala>> searchSalas(String query) {
    try {
      if (query.isEmpty) return getSalas();
      return _firestore
          .collection(_salasCollection)
          .orderBy('nombre')
          .startAt([query]).endAt(['$query\uf8ff'])
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Sala.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en searchSalas: $e');
      return Stream.value([]);
    }
  }

  Stream<List<Sala>> getSalasByComplejo(String complejoId) {
    try {
      if (complejoId.isEmpty) return Stream.value([]);
      return _firestore
          .collection(_salasCollection)
          .where('id_complejos', isEqualTo: complejoId)
          .orderBy('nombre')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Sala.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en getSalasByComplejo: $e');
      return Stream.value([]);
    }
  }

  // ========== PELICULAS CRUD ==========
  
  Stream<List<Pelicula>> getPeliculas() {
    try {
      print('Leyendo coleccion: $_peliculasCollection');
      return _firestore
          .collection(_peliculasCollection)
          .orderBy('nombre')
          .snapshots()
          .map((snapshot) {
        print('Peliculas encontradas: ${snapshot.docs.length}');
        return snapshot.docs
            .map((doc) => Pelicula.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en getPeliculas: $e');
      return Stream.value([]);
    }
  }

  Future<Pelicula?> getPeliculaById(String id) async {
    try {
      if (id.isEmpty) return null;
      DocumentSnapshot doc = await _firestore.collection(_peliculasCollection).doc(id).get();
      if (doc.exists) {
        return Pelicula.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error al obtener pelicula: $e');
      return null;
    }
  }

  Future<String?> createPelicula(Pelicula pelicula) async {
    try {
      DocumentReference docRef = await _firestore.collection(_peliculasCollection).add(pelicula.toMap());
      print('Pelicula creada: ${docRef.id} - ${pelicula.nombre}');
      return docRef.id;
    } catch (e) {
      print('Error al crear pelicula: $e');
      return null;
    }
  }

  Future<bool> updatePelicula(Pelicula pelicula) async {
    try {
      if (pelicula.id == null || pelicula.id!.isEmpty) return false;
      final docRef = _firestore.collection(_peliculasCollection).doc(pelicula.id);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        print('Pelicula no existe: ${pelicula.id}');
        return false;
      }
      await docRef.update(pelicula.toMap());
      print('Pelicula actualizada: ${pelicula.id} - ${pelicula.nombre}');
      return true;
    } catch (e) {
      print('Error al actualizar pelicula: $e');
      return false;
    }
  }

  Future<bool> deletePelicula(String id) async {
    try {
      if (id.isEmpty) {
        print('Error: ID de pelicula vacio');
        return false;
      }
      print('Intentando eliminar pelicula con ID: $id');
      final docRef = _firestore.collection(_peliculasCollection).doc(id);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        print('La pelicula no existe: $id');
        return false;
      }
      await docRef.delete();
      print('Pelicula eliminada correctamente: $id');
      return true;
    } catch (e) {
      print('Error al eliminar pelicula: $e');
      return false;
    }
  }

  Stream<List<Pelicula>> searchPeliculas(String query) {
    try {
      if (query.isEmpty) return getPeliculas();
      return _firestore
          .collection(_peliculasCollection)
          .orderBy('nombre')
          .startAt([query]).endAt(['$query\uf8ff'])
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Pelicula.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en searchPeliculas: $e');
      return Stream.value([]);
    }
  }

  Stream<List<Pelicula>> getPeliculasByGenero(String genero) {
    try {
      if (genero.isEmpty) return getPeliculas();
      return _firestore
          .collection(_peliculasCollection)
          .where('genero', isEqualTo: genero)
          .orderBy('nombre')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Pelicula.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en getPeliculasByGenero: $e');
      return Stream.value([]);
    }
  }

  // ========== FUNCIONES CRUD ==========
  
  Stream<List<Funcion>> getFunciones() {
    try {
      print('Leyendo coleccion: $_funcionesCollection');
      return _firestore
          .collection(_funcionesCollection)
          .orderBy('fecha_hora')
          .snapshots()
          .map((snapshot) {
        print('Funciones encontradas: ${snapshot.docs.length}');
        return snapshot.docs
            .map((doc) => Funcion.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en getFunciones: $e');
      return Stream.value([]);
    }
  }

  Future<Funcion?> getFuncionById(String id) async {
    try {
      if (id.isEmpty) return null;
      DocumentSnapshot doc = await _firestore.collection(_funcionesCollection).doc(id).get();
      if (doc.exists) {
        return Funcion.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error al obtener funcion: $e');
      return null;
    }
  }

  Future<Funcion?> getFuncionCompleta(String id) async {
    try {
      final funcion = await getFuncionById(id);
      if (funcion != null) {
        if (funcion.idPelicula.isNotEmpty) {
          final pelicula = await getPeliculaById(funcion.idPelicula);
          if (pelicula != null) {
            funcion.nombrePelicula = pelicula.nombre;
          }
        }
        if (funcion.idSala.isNotEmpty) {
          final sala = await getSalaById(funcion.idSala);
          if (sala != null) {
            funcion.nombreSala = sala.nombre;
          }
        }
        if (funcion.idComplejo.isNotEmpty) {
          final complejo = await getComplejoById(funcion.idComplejo);
          if (complejo != null) {
            funcion.nombreComplejo = complejo.nombre;
          }
        }
      }
      return funcion;
    } catch (e) {
      print('Error al obtener funcion completa: $e');
      return null;
    }
  }

  Future<String?> createFuncion(Funcion funcion) async {
    try {
      DocumentReference docRef = await _firestore.collection(_funcionesCollection).add(funcion.toMap());
      print('Funcion creada: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error al crear funcion: $e');
      return null;
    }
  }

  Future<bool> updateFuncion(Funcion funcion) async {
    try {
      if (funcion.id == null || funcion.id!.isEmpty) {
        print('Error: ID de función vacío');
        return false;
      }
      
      print('Actualizando función ID: ${funcion.id}');
      print('Nueva fecha: ${funcion.fechaHora}');
      
      final docRef = _firestore.collection(_funcionesCollection).doc(funcion.id);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        print('La función no existe: ${funcion.id}');
        return false;
      }
      
      await docRef.update(funcion.toMap());
      print('Función actualizada correctamente: ${funcion.id}');
      return true;
    } catch (e) {
      print('Error al actualizar función: $e');
      return false;
    }
  }

  Future<bool> deleteFuncion(String id) async {
    try {
      if (id.isEmpty) return false;
      final docRef = _firestore.collection(_funcionesCollection).doc(id);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        print('Funcion no existe: $id');
        return false;
      }
      await docRef.delete();
      print('Funcion eliminada: $id');
      return true;
    } catch (e) {
      print('Error al eliminar funcion: $e');
      return false;
    }
  }

  Stream<List<Funcion>> getFuncionesByPelicula(String peliculaId) {
    try {
      if (peliculaId.isEmpty) return Stream.value([]);
      return _firestore
          .collection(_funcionesCollection)
          .where('id_pelicula', isEqualTo: peliculaId)
          .orderBy('fecha_hora')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Funcion.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en getFuncionesByPelicula: $e');
      return Stream.value([]);
    }
  }

  Stream<List<Funcion>> getFuncionesDisponibles() {
    try {
      final now = DateTime.now();
      return _firestore
          .collection(_funcionesCollection)
          .where('fecha_hora', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('estado', isEqualTo: 'Disponible')
          .orderBy('fecha_hora')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Funcion.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en getFuncionesDisponibles: $e');
      return Stream.value([]);
    }
  }

  // ========== INVENTARIO CRUD ==========
  
  Stream<List<Inventario>> getInventario() {
    try {
      print('Leyendo coleccion: $_inventarioCollection');
      return _firestore
          .collection(_inventarioCollection)
          .orderBy('nombre')
          .snapshots()
          .map((snapshot) {
        print('Productos encontrados: ${snapshot.docs.length}');
        return snapshot.docs
            .map((doc) => Inventario.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en getInventario: $e');
      return Stream.value([]);
    }
  }

  Future<Inventario?> getInventarioById(String id) async {
    try {
      if (id.isEmpty) return null;
      DocumentSnapshot doc = await _firestore.collection(_inventarioCollection).doc(id).get();
      if (doc.exists) {
        return Inventario.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error al obtener producto: $e');
      return null;
    }
  }

  Future<String?> createInventario(Inventario producto) async {
    try {
      DocumentReference docRef = await _firestore.collection(_inventarioCollection).add(producto.toMap());
      print('Producto creado: ${docRef.id} - ${producto.nombre}');
      return docRef.id;
    } catch (e) {
      print('Error al crear producto: $e');
      return null;
    }
  }

  Future<bool> updateInventario(Inventario producto) async {
    try {
      if (producto.id == null || producto.id!.isEmpty) return false;
      final docRef = _firestore.collection(_inventarioCollection).doc(producto.id);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        print('Producto no existe: ${producto.id}');
        return false;
      }
      await docRef.update(producto.toMap());
      print('Producto actualizado: ${producto.id} - ${producto.nombre}');
      return true;
    } catch (e) {
      print('Error al actualizar producto: $e');
      return false;
    }
  }

  Future<bool> deleteInventario(String id) async {
    try {
      if (id.isEmpty) return false;
      final docRef = _firestore.collection(_inventarioCollection).doc(id);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        print('Producto no existe: $id');
        return false;
      }
      await docRef.delete();
      print('Producto eliminado: $id');
      return true;
    } catch (e) {
      print('Error al eliminar producto: $e');
      return false;
    }
  }

  Stream<List<Inventario>> searchInventario(String query) {
    try {
      if (query.isEmpty) return getInventario();
      return _firestore
          .collection(_inventarioCollection)
          .orderBy('nombre')
          .startAt([query]).endAt(['$query\uf8ff'])
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Inventario.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en searchInventario: $e');
      return Stream.value([]);
    }
  }

  Stream<List<Inventario>> getInventarioByCategoria(String categoria) {
    try {
      if (categoria.isEmpty) return getInventario();
      return _firestore
          .collection(_inventarioCollection)
          .where('categoria', isEqualTo: categoria)
          .orderBy('nombre')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Inventario.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en getInventarioByCategoria: $e');
      return Stream.value([]);
    }
  }

  Stream<List<Inventario>> getInventarioStockBajo() {
    try {
      return _firestore
          .collection(_inventarioCollection)
          .where('stock_disponible', isLessThan: 10)
          .where('estado', isEqualTo: 'Disponible')
          .orderBy('stock_disponible')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Inventario.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error en getInventarioStockBajo: $e');
      return Stream.value([]);
    }
  }
    // ========== NUEVOS MÉTODOS PARA ACTUALIZAR STOCK ==========
  
  Future<bool> actualizarStockAlimento(String productoId, int cantidadRestar) async {
    try {
      final productoRef = _firestore.collection(_inventarioCollection).doc(productoId);
      
      // Obtener el stock actual
      final doc = await productoRef.get();
      if (!doc.exists) {
        print('Producto no encontrado: $productoId');
        return false;
      }
      
      final stockActual = (doc.data()?['stock_disponible'] ?? 0).toInt();
      final nuevoStock = stockActual - cantidadRestar;
      
      if (nuevoStock < 0) {
        print('Stock insuficiente para producto $productoId. Stock actual: $stockActual, Cantidad a restar: $cantidadRestar');
        return false;
      }
      
      // Actualizar stock
      await productoRef.update({
        'stock_disponible': nuevoStock,
      });
      
      // Actualizar estado automáticamente basado en el nuevo stock
      String nuevoEstado = 'Disponible';
      if (nuevoStock <= 0) {
        nuevoEstado = 'Agotado';
      } else if (nuevoStock <= 10) {
        nuevoEstado = 'Poco Stock';
      }
      
      await productoRef.update({
        'estado': nuevoEstado,
      });
      
      print('Stock actualizado - Producto: $productoId, Stock anterior: $stockActual, Nuevo stock: $nuevoStock, Estado: $nuevoEstado');
      return true;
    } catch (e) {
      print('Error al actualizar stock: $e');
      return false;
    }
  }

  // ========== USUARIOS CRUD ==========

Stream<List<Usuario>> getUsuarios() {
  try {
    return _firestore
        .collection('Usuarios')
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Usuario.fromFirestore(doc.data(), doc.id))
          .toList();
    }).handleError((error) {
      print('Error en getUsuarios: $error');
      return <Usuario>[];
    });
  } catch (e) {
    print('Error en getUsuarios: $e');
    return Stream.value([]);
  }
}

Future<Usuario?> getUsuarioById(String id) async {
  try {
    if (id.isEmpty) return null;
    DocumentSnapshot doc = await _firestore.collection('Usuarios').doc(id).get();
    if (doc.exists) {
      return Usuario.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  } catch (e) {
    print('Error al obtener usuario: $e');
    return null;
  }
}

Future<String?> createUsuario(Usuario usuario) async {
  try {
    DocumentReference docRef = await _firestore.collection('Usuarios').add(usuario.toMap());
    print('Usuario creado: ${docRef.id} - ${usuario.nombre}');
    return docRef.id;
  } catch (e) {
    print('Error al crear usuario: $e');
    return null;
  }
}

Future<bool> updateUsuario(Usuario usuario) async {
  try {
    if (usuario.id == null || usuario.id!.isEmpty) return false;
    final docRef = _firestore.collection('Usuarios').doc(usuario.id);
    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      print('Usuario no existe: ${usuario.id}');
      return false;
    }
    await docRef.update(usuario.toMap());
    print('Usuario actualizado: ${usuario.id} - ${usuario.nombre}');
    return true;
  } catch (e) {
    print('Error al actualizar usuario: $e');
    return false;
  }
}

Future<bool> deleteUsuario(String id) async {
  try {
    if (id.isEmpty) return false;
    final docRef = _firestore.collection('Usuarios').doc(id);
    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      print('Usuario no existe: $id');
      return false;
    }
    await docRef.delete();
    print('Usuario eliminado: $id');
    return true;
  } catch (e) {
    print('Error al eliminar usuario: $e');
    return false;
  }
}

  // ========== PEDIDOS CRUD ==========
  
// Crear un nuevo pedido
Future<String?> createPedido(Pedido pedido) async {
  try {
    DocumentReference docRef = await _firestore.collection(_pedidosCollection).add(pedido.toMap());
    print('Pedido creado: ${docRef.id}');
    return docRef.id;
  } catch (e) {
    print('Error al crear pedido: $e');
    return null;
  }
}

// Obtener todos los pedidos (para admin)
Stream<List<Pedido>> getPedidos() {
  try {
    return _firestore
        .collection(_pedidosCollection)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Pedido.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  } catch (e) {
    print('Error en getPedidos: $e');
    return Stream.value([]);
  }
}

// Obtener pedidos de un cliente específico
Stream<List<Pedido>> getPedidosByCliente(String clienteId) {
  try {
    if (clienteId.isEmpty) return Stream.value([]);
    return _firestore
        .collection(_pedidosCollection)
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Pedido.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  } catch (e) {
    print('Error en getPedidosByCliente: $e');
    return Stream.value([]);
  }
}

// Obtener un pedido por ID
Future<Pedido?> getPedidoById(String id) async {
  try {
    if (id.isEmpty) return null;
    DocumentSnapshot doc = await _firestore.collection(_pedidosCollection).doc(id).get();
    if (doc.exists) {
      return Pedido.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  } catch (e) {
    print('Error al obtener pedido: $e');
    return null;
  }
}

// Actualizar estado del pedido
Future<bool> updatePedidoEstado(String pedidoId, String estado) async {
  try {
    if (pedidoId.isEmpty) return false;
    await _firestore.collection(_pedidosCollection).doc(pedidoId).update({
      'estado': estado,
    });
    print('Pedido actualizado: $pedidoId - Estado: $estado');
    return true;
  } catch (e) {
    print('Error al actualizar pedido: $e');
    return false;
  }
}

// Actualizar pedido completo
Future<bool> updatePedido(Pedido pedido) async {
  try {
    if (pedido.id == null || pedido.id!.isEmpty) return false;
    final docRef = _firestore.collection(_pedidosCollection).doc(pedido.id);
    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      print('Pedido no existe: ${pedido.id}');
      return false;
    }
    await docRef.update(pedido.toMap());
    print('Pedido actualizado: ${pedido.id}');
    return true;
  } catch (e) {
    print('Error al actualizar pedido: $e');
    return false;
  }
}

// ========== PUNTOS CINÉPOLIS ==========

// Sumar puntos al usuario
Future<bool> agregarPuntosCliente({
  required String clienteId,
  required int puntosAgregar,
}) async {
  try {
    if (clienteId.isEmpty) return false;

    final docRef = _firestore.collection('Usuarios').doc(clienteId);

    final doc = await docRef.get();

    if (!doc.exists) {
      print('Usuario no encontrado');
      return false;
    }

    final data = doc.data() as Map<String, dynamic>;

    int puntosActuales = 0;

    if (data['puntos_cinepolis'] != null) {
      puntosActuales = (data['puntos_cinepolis'] as num).toInt();
    }

    int nuevosPuntos = puntosActuales + puntosAgregar;

    await docRef.update({
      'puntos_cinepolis': nuevosPuntos,
    });

    print('Puntos actualizados: $nuevosPuntos');

    return true;
  } catch (e) {
    print('Error al agregar puntos: $e');
    return false;
  }
}

// Eliminar un pedido (solo admin)
Future<bool> deletePedido(String id) async {
  try {
    if (id.isEmpty) return false;
    final docRef = _firestore.collection(_pedidosCollection).doc(id);
    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      print('Pedido no existe: $id');
      return false;
    }
    await docRef.delete();
    print('Pedido eliminado: $id');
    return true;
  } catch (e) {
    print('Error al eliminar pedido: $e');
    return false;
  }
}

// Obtener pedidos por método de pago
Stream<List<Pedido>> getPedidosByMetodoPago(String metodoPago) {
  try {
    if (metodoPago.isEmpty) return Stream.value([]);
    return _firestore
        .collection(_pedidosCollection)
        .where('metodoPago', isEqualTo: metodoPago)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Pedido.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  } catch (e) {
    print('Error en getPedidosByMetodoPago: $e');
    return Stream.value([]);
  }
}

// Obtener pedidos por estado
Stream<List<Pedido>> getPedidosByEstado(String estado) {
  try {
    if (estado.isEmpty) return Stream.value([]);
    return _firestore
        .collection(_pedidosCollection)
        .where('estado', isEqualTo: estado)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Pedido.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  } catch (e) {
    print('Error en getPedidosByEstado: $e');
    return Stream.value([]);
  }
}

// Obtener pedidos por rango de fechas
Stream<List<Pedido>> getPedidosByFechaRange(DateTime startDate, DateTime endDate) {
  try {
    return _firestore
        .collection(_pedidosCollection)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Pedido.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  } catch (e) {
    print('Error en getPedidosByFechaRange: $e');
    return Stream.value([]);
  }
}

// Obtener total de ventas (suma de todos los pedidos)
Future<double> getTotalVentas() async {
  try {
    final snapshot = await _firestore.collection(_pedidosCollection).get();
    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['total'] ?? 0).toDouble();
    }
    return total;
  } catch (e) {
    print('Error al obtener total de ventas: $e');
    return 0;
  }
}

// Obtener total de ventas por fecha
Future<double> getTotalVentasByFecha(DateTime fecha) async {
  try {
    final startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final snapshot = await _firestore
        .collection(_pedidosCollection)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('fecha', isLessThan: Timestamp.fromDate(endOfDay))
        .get();
    
    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['total'] ?? 0).toDouble();
    }
    return total;
  } catch (e) {
    print('Error al obtener total de ventas por fecha: $e');
    return 0;
  }
}

  // ========== METODOS DE UTILERIA ==========
  
  Future<bool> verificarConexion() async {
    try {
      await _firestore.collection(_peliculasCollection).limit(1).get();
      print('Conexion a Firebase exitosa');
      return true;
    } catch (e) {
      print('Error de conexion a Firebase: $e');
      return false;
    }
  }
  
  Future<int> getConteo(String coleccion) async {
    try {
      final snapshot = await _firestore.collection(coleccion).get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error al obtener conteo de $coleccion: $e');
      return 0;
    }
  }
}