import '../adapters/cliente_adapter.dart';
import '../services/auth_service.dart';
import 'base_view_model.dart';

class LoginViewModel extends BaseViewModel {
  final AuthService _authService = AuthService();
  final ClienteAdapter _clienteAdapter = ClienteAdapter();

  Future<bool> login(String emailOuCpf, String senha) async {
    if (emailOuCpf.isEmpty || senha.isEmpty) {
      showError('Por favor, preencha todos os campos.');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      String emailParaLogin = emailOuCpf.trim();

      // Verificar se é CPF (11 dígitos numéricos)
      if (_isCpf(emailOuCpf.trim())) {
        // Limpar CPF (remover pontos, hífens, espaços)
        final cpfLimpo = emailOuCpf.trim().replaceAll(RegExp(r'[^0-9]'), '');

        // Buscar email pelo CPF na clientDb
        final cliente = await _clienteAdapter.buscarClientePorCpf(cpfLimpo);

        if (cliente == null) {
          throw Exception('CPF não encontrado');
        }

        emailParaLogin = cliente.email;
      }

      // Tenta fazer login com Firebase usando o email
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: emailParaLogin,
        password: senha,
      );

      setLoading(false);
      return userCredential != null;
    } catch (e) {
      setLoading(false);
      showError(e.toString());
      return false;
    }
  }

  // Método para verificar se o texto é um CPF válido
  bool _isCpf(String texto) {
    // Remove espaços, pontos e hífens e verifica se tem exatamente 11 dígitos
    final cpfLimpo = texto.replaceAll(RegExp(r'[^0-9]'), '');
    return cpfLimpo.length == 11 && RegExp(r'^\d{11}$').hasMatch(cpfLimpo);
  }
}
