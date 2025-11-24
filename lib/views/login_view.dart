import 'package:flutter/material.dart';
import '../viewmodels/login_view_model.dart';
import 'cadastro_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailOuCpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final LoginViewModel _viewModel = LoginViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChange);
  }

  void _onViewModelChange() {
    if (_viewModel.hasError) {
      _mostrarMensagem(_viewModel.errorMessage!, isError: true);
    }
  }

  Future<void> _fazerLogin() async {
    final sucesso = await _viewModel.login(
      _emailOuCpfController.text,
      _senhaController.text,
    );

    if (sucesso && mounted) {
      _mostrarMensagem('Login realizado com sucesso!');
      Navigator.pushReplacementNamed(context, '/menu');
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
                  labelText: 'Email ou CPF',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Senha
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botão Entrar
              SizedBox(
                width: double.infinity,
                child: ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, child) {
                    return ElevatedButton(
                      onPressed: _viewModel.isLoading ? null : _fazerLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _viewModel.isLoading
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
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Link Cadastrar-se
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CadastroView(),
                    ),
                  );
                },
                child: const Text(
                  "Não tem uma conta? Cadastrar-se",
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w500,
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
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }
}
