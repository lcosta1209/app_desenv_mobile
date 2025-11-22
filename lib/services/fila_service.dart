import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fila.dart';

class FilaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'fila';

  // Adicionar um cliente na fila
  Future<String> adicionarNaFila({
    required String clienteId,
    required String clienteNome,
    required String clienteEmail,
  }) async {
    try {
      // Buscar a próxima posição disponível
      int proximaPosicao = await _obterProximaPosicao();

      ItemFila novoItem = ItemFila(
        clienteId: clienteId,
        clienteNome: clienteNome,
        clienteEmail: clienteEmail,
        dataHoraEntrada: DateTime.now(),
        posicao: proximaPosicao,
        status: 'aguardando',
      );

      DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(novoItem.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao adicionar na fila: $e');
    }
  }

  // Obter a próxima posição na fila
  Future<int> _obterProximaPosicao() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: 'aguardando')
          .orderBy('posicao', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return 1; // Primeira posição
      }

      int ultimaPosicao = snapshot.docs.first['posicao'] as int;
      return ultimaPosicao + 1;
    } catch (e) {
      return 1; // Se houver erro, começa da posição 1
    }
  }

  // Buscar todos os itens da fila (aguardando)
  Stream<List<ItemFila>> obterFila() {
    return _firestore
        .collection(_collectionName)
        .where('status', isEqualTo: 'aguardando')
        .orderBy('posicao')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ItemFila.fromFirestore(doc);
          }).toList();
        });
  }

  // Buscar posição de um cliente específico na fila
  Future<ItemFila?> buscarPosicaoCliente(String clienteId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('clienteId', isEqualTo: clienteId)
          .where('status', isEqualTo: 'aguardando')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return ItemFila.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Erro ao buscar posição do cliente: $e');
    }
  }

  // Verificar se o cliente já está na fila
  Future<bool> clienteJaNaFila(String clienteId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('clienteId', isEqualTo: clienteId)
          .where('status', isEqualTo: 'aguardando')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Chamar próximo da fila (atualizar status)
  Future<void> chamarProximo() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: 'aguardando')
          .orderBy('posicao')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'status': 'em_atendimento',
        });
      }
    } catch (e) {
      throw Exception('Erro ao chamar próximo: $e');
    }
  }

  // Remover da fila (cancelar)
  Future<void> removerDaFila(String itemId) async {
    try {
      await _firestore.collection(_collectionName).doc(itemId).update({
        'status': 'cancelado',
      });
    } catch (e) {
      throw Exception('Erro ao remover da fila: $e');
    }
  }

  // Finalizar atendimento
  Future<void> finalizarAtendimento(String itemId) async {
    try {
      await _firestore.collection(_collectionName).doc(itemId).update({
        'status': 'atendido',
      });
    } catch (e) {
      throw Exception('Erro ao finalizar atendimento: $e');
    }
  }

  // Contar quantas pessoas estão aguardando
  Future<int> contarPessoasNaFila() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: 'aguardando')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Calcular tempo estimado de espera (assumindo 10 minutos por pessoa)
  Future<int> calcularTempoEstimado(int posicao) async {
    // Tempo médio de atendimento em minutos
    const int tempoMedioPorPessoa = 10;

    // Calcula o tempo estimado baseado na posição
    // Subtrai 1 porque a pessoa na posição 1 já está sendo atendida
    int tempoEstimado = (posicao - 1) * tempoMedioPorPessoa;

    return tempoEstimado > 0 ? tempoEstimado : 5; // Mínimo de 5 minutos
  }
}
