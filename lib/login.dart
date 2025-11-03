import 'package:flutter/material.dart';
import 'tela_cadastro.dart';
import 'services/auth_service.dart';
import 'adapters/cliente_adapter.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _emailOuCpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final AuthService _authService = AuthService();
  final ClienteAdapter _clienteAdapter = ClienteAdapter();
  bool _isLoading = false;

  Future<void> _fazerLogin() async {
    if (_emailOuCpfController.text.isEmpty || _senhaController.text.isEmpty) {
      _mostrarMensagem('Por favor, preencha todos os campos.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String emailParaLogin = _emailOuCpfController.text.trim();

      // Verificar se é CPF (11 dígitos numéricos)
      if (_isCpf(_emailOuCpfController.text.trim())) {
        // Limpar CPF (remover pontos, hífens, espaços)
        final cpfLimpo = _emailOuCpfController.text.trim().replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );

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
        password: _senhaController.text,
      );

      if (mounted && userCredential != null) {
        // Login bem-sucedido - navega para o menu
        _mostrarMensagem('Login realizado com sucesso!');
        Navigator.pushReplacementNamed(context, '/menu');
      }
    } catch (e) {
      if (mounted) {
        _mostrarMensagem(e.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Método para verificar se o texto é um CPF válido
  bool _isCpf(String texto) {
    // Remove espaços, pontos e hífens e verifica se tem exatamente 11 dígitos
    final cpfLimpo = texto.replaceAll(RegExp(r'[^0-9]'), '');
    return cpfLimpo.length == 11 && RegExp(r'^\d{11}$').hasMatch(cpfLimpo);
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
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
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "+",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E5AAC),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              const Text(
                "Entrar",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              // Email ou CPF
              TextField(
                controller: _emailOuCpfController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "CPF / Email",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Senha
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Senha",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botão Entrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _fazerLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5AAC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                          "Entrar",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // Link Cadastrar-se
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TelaCadastro(),
                    ),
                  );
                },
                child: const Text(
                  "Cadastrar-se",
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailOuCpfController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}
