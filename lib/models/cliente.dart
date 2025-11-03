class Cliente {
  final String? id;
  final String nome;
  final String email;
  final String cpf;
  final String? senha;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  Cliente({
    this.id,
    required this.nome,
    required this.email,
    required this.cpf,
    this.senha,
    this.criadoEm,
    this.atualizadoEm,
  });

  // Converter para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'criadoEm': criadoEm,
      'atualizadoEm': atualizadoEm,
    };
  }

  // Criar Cliente a partir de Map (do Firestore)
  factory Cliente.fromMap(Map<String, dynamic> map, String id) {
    return Cliente(
      id: id,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'] ?? '',
      criadoEm: map['criadoEm']?.toDate(),
      atualizadoEm: map['atualizadoEm']?.toDate(),
    );
  }

  // Criar cópia com modificações
  Cliente copyWith({
    String? id,
    String? nome,
    String? email,
    String? cpf,
    String? senha,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      senha: senha ?? this.senha,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return 'Cliente{id: $id, nome: $nome, email: $email, cpf: $cpf}';
  }
}
