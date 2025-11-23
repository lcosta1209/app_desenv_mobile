import '../models/cliente.dart';
import '../services/cliente_firebase_service.dart';

class ClienteAdapter {
  final ClienteFirebaseService _firebaseService = ClienteFirebaseService();

  // Criar novo cliente
  Future<String> criarCliente({
    required String nome,
    required String email,
    required String cpf,
    String? dataNascimento,
    String? telefone,
  }) async {
    try {
      // Criar cliente (as validações de email e CPF já foram feitas na tela)
      final cliente = Cliente(
        nome: nome,
        email: email,
        cpf: cpf,
        dataNascimento: dataNascimento,
        telefone: telefone,
      );

      final clienteId = await _firebaseService.criarCliente(cliente);
      return clienteId;
    } catch (e) {
      throw Exception('Erro ao criar cliente: $e');
    }
  }

  // Buscar cliente por ID
  Future<Cliente?> buscarClientePorId(String id) async {
    try {
      return await _firebaseService.buscarClientePorId(id);
    } catch (e) {
      throw Exception('Erro ao buscar cliente: $e');
    }
  }

  // Buscar cliente por email
  Future<Cliente?> buscarClientePorEmail(String email) async {
    try {
      return await _firebaseService.buscarClientePorEmail(email);
    } catch (e) {
      throw Exception('Erro ao buscar cliente por email: $e');
    }
  }

  // Buscar cliente por CPF
  Future<Cliente?> buscarClientePorCpf(String cpf) async {
    try {
      return await _firebaseService.buscarClientePorCpf(cpf);
    } catch (e) {
      throw Exception('Erro ao buscar cliente por CPF: $e');
    }
  }

  // Listar todos os clientes
  Future<List<Cliente>> listarTodosClientes() async {
    try {
      return await _firebaseService.listarClientes();
    } catch (e) {
      throw Exception('Erro ao listar clientes: $e');
    }
  }

  // Atualizar cliente
  Future<void> atualizarCliente({
    required String id,
    required String nome,
    required String email,
    required String cpf,
  }) async {
    try {
      // Buscar cliente atual
      final clienteAtual = await _firebaseService.buscarClientePorId(id);
      if (clienteAtual == null) {
        throw Exception('Cliente não encontrado');
      }

      // Verificar se email já existe (exceto o próprio cliente)
      if (email != clienteAtual.email) {
        final emailJaExiste = await _firebaseService.emailExiste(email);
        if (emailJaExiste) {
          throw Exception('Email já está cadastrado por outro cliente');
        }
      }

      // Verificar se CPF já existe (exceto o próprio cliente)
      if (cpf != clienteAtual.cpf) {
        final cpfJaExiste = await _firebaseService.cpfExiste(cpf);
        if (cpfJaExiste) {
          throw Exception('CPF já está cadastrado por outro cliente');
        }
      }

      // Atualizar cliente
      final clienteAtualizado = clienteAtual.copyWith(
        nome: nome,
        email: email,
        cpf: cpf,
      );

      await _firebaseService.atualizarCliente(id, clienteAtualizado);
    } catch (e) {
      throw Exception('Erro ao atualizar cliente: $e');
    }
  }

  // Deletar cliente
  Future<void> deletarCliente(String id) async {
    try {
      await _firebaseService.deletarCliente(id);
    } catch (e) {
      throw Exception('Erro ao deletar cliente: $e');
    }
  }

  // Stream para escutar mudanças em tempo real
  Stream<List<Cliente>> escutarClientes() {
    return _firebaseService.streamClientes();
  }

  // Validar dados do cliente
  String? validarNome(String? nome) {
    if (nome == null || nome.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (nome.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? validarEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Email inválido';
    }
    return null;
  }

  String? validarCpf(String? cpf) {
    if (cpf == null || cpf.trim().isEmpty) {
      return 'CPF é obrigatório';
    }
    if (cpf.length != 11) {
      return 'CPF deve ter exatamente 11 dígitos';
    }
    if (!RegExp(r'^\d+$').hasMatch(cpf)) {
      return 'CPF deve conter apenas números';
    }
    return null;
  }

  // Verificar se email existe
  Future<bool> emailExiste(String email) async {
    try {
      return await _firebaseService.emailExiste(email);
    } catch (e) {
      throw Exception('Erro ao verificar email: $e');
    }
  }

  // Verificar se CPF existe
  Future<bool> cpfExiste(String cpf) async {
    try {
      return await _firebaseService.cpfExiste(cpf);
    } catch (e) {
      throw Exception('Erro ao verificar CPF: $e');
    }
  }

  // Verificar se cliente existe por email ou CPF
  Future<bool> clienteExiste({String? email, String? cpf}) async {
    try {
      if (email != null) {
        final emailExiste = await _firebaseService.emailExiste(email);
        if (emailExiste) return true;
      }

      if (cpf != null) {
        final cpfExiste = await _firebaseService.cpfExiste(cpf);
        if (cpfExiste) return true;
      }

      return false;
    } catch (e) {
      throw Exception('Erro ao verificar se cliente existe: $e');
    }
  }
}
