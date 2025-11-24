import '../services/auth_service.dart';
import 'base_view_model.dart';

class MenuViewModel extends BaseViewModel {
  final AuthService _authService = AuthService();

  Future<bool> logout() async {
    setLoading(true);
    clearError();

    try {
      await _authService.signOut();
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      showError('Erro ao fazer logout: $e');
      return false;
    }
  }
}
