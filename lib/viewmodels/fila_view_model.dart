import '../models/fila.dart';
import '../services/auth_service.dart';
import '../services/fila_service.dart';
import 'base_view_model.dart';

class FilaViewModel extends BaseViewModel {
  final FilaService _filaService = FilaService();
  final AuthService _authService = AuthService();

  ItemFila? _minhaPosicao;
  int _tempoEstimado = 0;

  ItemFila? get minhaPosicao => _minhaPosicao;
  int get tempoEstimado => _tempoEstimado;

  Future<void> carregarDadosFila() async {
    setLoading(true);
    clearError();

    try {
      final user = _authService.currentUser;
      if (user == null) {
        setLoading(false);
        showError('Usuário não autenticado');
        return;
      }

      // Buscar posição do cliente na fila
      final posicao = await _filaService.buscarPosicaoCliente(user.uid);

      if (posicao == null) {
        setLoading(false);
        showError('Você não está na fila');
        return;
      }

      // Calcular tempo estimado
      final tempo = await _filaService.calcularTempoEstimado(posicao.posicao);

      _minhaPosicao = posicao;
      _tempoEstimado = tempo;
      setLoading(false);
      notifyListeners();
    } catch (e) {
      setLoading(false);
      showError('Erro ao carregar dados: $e');
    }
  }

  Future<bool> sairDaFila() async {
    if (_minhaPosicao?.id == null) {
      showError('Erro: posição na fila não encontrada');
      return false;
    }

    try {
      await _filaService.removerDaFila(_minhaPosicao!.id!);
      return true;
    } catch (e) {
      showError('Erro ao sair da fila: $e');
      return false;
    }
  }
}
