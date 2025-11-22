import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/fila_service.dart';
import 'tela_fila.dart';

class TelaNovoAtendimento extends StatefulWidget {
  const TelaNovoAtendimento({super.key});

  @override
  State<TelaNovoAtendimento> createState() => _TelaNovoAtendimentoState();
}

class _TelaNovoAtendimentoState extends State<TelaNovoAtendimento> {
  final FilaService _filaService = FilaService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _entrarNaFila() async {
    final user = _authService.currentUser;
    if (user == null) {
      _mostrarMensagem('Usuário não autenticado', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar se o usuário já está na fila
      final jaEstaNaFila = await _filaService.clienteJaNaFila(user.uid);

      if (jaEstaNaFila) {
        if (mounted) {
          _mostrarMensagem('Você já está na fila!', isError: true);
          // Navegar para a tela de fila mesmo assim
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TelaFila()),
          );
        }
        return;
      }

      // Adicionar na fila
      await _filaService.adicionarNaFila(
        clienteId: user.uid,
        clienteNome: user.displayName ?? user.email ?? 'Usuário',
        clienteEmail: user.email ?? '',
      );

      if (mounted) {
        _mostrarMensagem('Você entrou na fila com sucesso!');

        // Navegar para a tela de fila
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaFila()),
        );
      }
    } catch (e) {
      if (mounted) {
        _mostrarMensagem('Erro ao entrar na fila: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mostrarMensagem(String mensagem, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A8A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Novo Atendimento",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ATENDI+
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "ATENDI",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "+",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Ícone de fila
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_outline,
                  size: 80,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 40),

              // Título
              const Text(
                "Entrar na Fila",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Descrição
              const Text(
                "Clique no botão abaixo para entrar na fila de atendimento.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Botão Entrar na Fila
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _entrarNaFila,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Entrar na Fila",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
