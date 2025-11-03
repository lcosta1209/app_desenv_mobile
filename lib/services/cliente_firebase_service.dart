import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cliente.dart';

class ClienteFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'clientDb';

  // Criar cliente
  Future<String> criarCliente(Cliente cliente) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add({
        ...cliente.toMap(),
        'criadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar cliente: $e');
    }
  }

  // Buscar cliente por ID
  Future<Cliente?> buscarClientePorId(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();

      if (doc.exists && doc.data() != null) {
        return Cliente.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar cliente: $e');
    }
  }

  // Buscar cliente por email
  Future<Cliente?> buscarClientePorEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return Cliente.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar cliente por email: $e');
    }
  }

  // Buscar cliente por CPF
  Future<Cliente?> buscarClientePorCpf(String cpf) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('cpf', isEqualTo: cpf)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return Cliente.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar cliente por CPF: $e');
    }
  }

  // Listar todos os clientes
  Future<List<Cliente>> listarClientes() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('criadoEm', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Cliente.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar clientes: $e');
    }
  }

  // Atualizar cliente
  Future<void> atualizarCliente(String id, Cliente cliente) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'nome': cliente.nome,
        'email': cliente.email,
        'cpf': cliente.cpf,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar cliente: $e');
    }
  }

  // Deletar cliente
  Future<void> deletarCliente(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar cliente: $e');
    }
  }

  // Stream para escutar mudanças em tempo real
  Stream<List<Cliente>> streamClientes() {
    return _firestore
        .collection(_collectionName)
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Cliente.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Verificar se email já existe
  Future<bool> emailExiste(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Erro ao verificar email: $e');

      // Se for erro de permissão, assumir que email não existe para permitir cadastro
      if (e.toString().contains('permission-denied') ||
          e.toString().contains('PERMISSION_DENIED')) {
        print(
          '⚠️ Erro de permissão detectado. Permitindo verificação de email.',
        );
        return false;
      }

      throw Exception('Erro ao verificar email: $e');
    }
  }

  // Verificar se CPF já existe
  Future<bool> cpfExiste(String cpf) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('cpf', isEqualTo: cpf)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Erro ao verificar CPF: $e');

      // Se for erro de permissão, assumir que CPF não existe para permitir cadastro
      if (e.toString().contains('permission-denied') ||
          e.toString().contains('PERMISSION_DENIED')) {
        print('⚠️ Erro de permissão detectado. Permitindo verificação de CPF.');
        return false;
      }

      throw Exception('Erro ao verificar CPF: $e');
    }
  }
}
