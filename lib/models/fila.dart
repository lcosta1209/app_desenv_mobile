import 'package:cloud_firestore/cloud_firestore.dart';

class ItemFila {
  String? id;
  String clienteId;
  String clienteNome;
  String clienteEmail;
  DateTime dataHoraEntrada;
  int posicao;
  String status; // 'aguardando', 'em_atendimento', 'atendido', 'cancelado'

  ItemFila({
    this.id,
    required this.clienteId,
    required this.clienteNome,
    required this.clienteEmail,
    required this.dataHoraEntrada,
    required this.posicao,
    this.status = 'aguardando',
  });

  // Converter para Map para salvar no Firebase
  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'clienteEmail': clienteEmail,
      'dataHoraEntrada': Timestamp.fromDate(dataHoraEntrada),
      'posicao': posicao,
      'status': status,
    };
  }

  // Criar ItemFila a partir de um DocumentSnapshot do Firebase
  factory ItemFila.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ItemFila(
      id: doc.id,
      clienteId: data['clienteId'] ?? '',
      clienteNome: data['clienteNome'] ?? '',
      clienteEmail: data['clienteEmail'] ?? '',
      dataHoraEntrada: (data['dataHoraEntrada'] as Timestamp).toDate(),
      posicao: data['posicao'] ?? 0,
      status: data['status'] ?? 'aguardando',
    );
  }

  // Criar ItemFila a partir de um Map
  factory ItemFila.fromMap(Map<String, dynamic> map, String id) {
    return ItemFila(
      id: id,
      clienteId: map['clienteId'] ?? '',
      clienteNome: map['clienteNome'] ?? '',
      clienteEmail: map['clienteEmail'] ?? '',
      dataHoraEntrada: (map['dataHoraEntrada'] as Timestamp).toDate(),
      posicao: map['posicao'] ?? 0,
      status: map['status'] ?? 'aguardando',
    );
  }
}
