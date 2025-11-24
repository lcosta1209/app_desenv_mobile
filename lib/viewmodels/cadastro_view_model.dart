import '../adapters/cliente_adapter.dart';
import '../services/auth_service.dart';
import 'base_view_model.dart';

class CadastroViewModel extends BaseViewModel {
  final AuthService _authService = AuthService();
  final ClienteAdapter _clienteAdapter = ClienteAdapter();

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String cpf,
    required String senha,
    String? dataNascimento,
    String? telefone,
  }) async {
    setLoading(true);
    clearError();

    try {
      // Primeiro: Verificar se dados do cliente são válidos (email e CPF únicos)
      final emailJaExiste = await _clienteAdapter.emailExiste(email.trim());
      if (emailJaExiste) {
        throw Exception('Email já está cadastrado');
      }

      final cpfJaExiste = await _clienteAdapter.cpfExiste(cpf.trim());
      if (cpfJaExiste) {
        throw Exception('CPF já está cadastrado');
      }

      // Segundo: Salvar dados do cliente na collection clientDb PRIMEIRO
      final clienteId = await _clienteAdapter.criarCliente(
        nome: nome.trim(),
        email: email.trim(),
        cpf: cpf.trim(),
        dataNascimento: dataNascimento?.trim().isEmpty == true
            ? null
            : dataNascimento?.trim(),
        telefone: telefone?.trim().isEmpty == true ? null : telefone?.trim(),
      );

      try {
        // Terceiro: Só após salvar com sucesso na clientDb, criar usuário no Firebase Auth
        final userCredential = await _authService.registerWithEmailAndPassword(
          email: email.trim(),
          password: senha,
        );

        setLoading(false);
        return userCredential != null && userCredential.user != null;
      } catch (authError) {
        // Se der erro na criação do usuário Auth, remover o cliente da clientDb
        try {
          await _clienteAdapter.deletarCliente(clienteId);
          print(
            'Cliente removido da clientDb devido a erro no Auth: $authError',
          );
        } catch (deleteError) {
          print('Erro ao remover cliente após falha no Auth: $deleteError');
        }

        // Re-lançar o erro original do Auth
        rethrow;
      }
    } catch (e) {
      setLoading(false);
      showError(e.toString());
      return false;
    }
  }

  // Validações
  String? validarNome(String? nome) {
    return _clienteAdapter.validarNome(nome);
  }

  String? validarEmail(String? email) {
    return _clienteAdapter.validarEmail(email);
  }

  String? validarCpf(String? cpf) {
    return _clienteAdapter.validarCpf(cpf);
  }

  String? validarSenha(String? senha) {
    if (senha == null || senha.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (senha.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }
}
