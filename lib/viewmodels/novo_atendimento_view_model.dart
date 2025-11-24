import '../services/auth_service.dart';
import '../services/fila_service.dart';
import 'base_view_model.dart';

class NovoAtendimentoViewModel extends BaseViewModel {
  final FilaService _filaService = FilaService();
  final AuthService _authService = AuthService();

  int _proximaPosicao = 1;
  int _pessoasNaFila = 0;

  int get proximaPosicao => _proximaPosicao;
  int get pessoasNaFila => _pessoasNaFila;

  Future<void> carregarInformacoesFila() async {
    try {
      final pessoasNaFila = await _filaService.contarPessoasNaFila();
      final proximaPosicao = await _filaService.obterProximaPosicao();

      _pessoasNaFila = pessoasNaFila;
      _proximaPosicao = proximaPosicao;
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar informações da fila: $e');
      showError('Erro ao carregar informações da fila');
    }
  }

  Future<bool> entrarNaFila() async {
    final user = _authService.currentUser;
    if (user == null) {
      showError('Usuário não autenticado');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      // Verificar se o usuário já está na fila
      final jaEstaNaFila = await _filaService.clienteJaNaFila(user.uid);

      if (jaEstaNaFila) {
        showError('Você já está na fila!');
        setLoading(false);
        return true; // Retorna true para navegar para a tela de fila
      }

      // Adicionar na fila
      await _filaService.adicionarNaFila(
        clienteId: user.uid,
        clienteNome: user.displayName ?? user.email ?? 'Usuário',
        clienteEmail: user.email ?? '',
      );

      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      showError('Erro ao entrar na fila: $e');
      return false;
    }
  }
}
