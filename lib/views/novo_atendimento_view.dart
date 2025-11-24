import 'package:flutter/material.dart';
import '../viewmodels/novo_atendimento_view_model.dart';
import 'fila_view.dart';

class NovoAtendimentoView extends StatefulWidget {
  const NovoAtendimentoView({super.key});

  @override
  State<NovoAtendimentoView> createState() => _NovoAtendimentoViewState();
}

class _NovoAtendimentoViewState extends State<NovoAtendimentoView> {
  final NovoAtendimentoViewModel _viewModel = NovoAtendimentoViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChange);
    _viewModel.carregarInformacoesFila();
  }

  void _onViewModelChange() {
    if (_viewModel.hasError) {
      _mostrarMensagem(_viewModel.errorMessage!, isError: true);
    }
  }

  Future<void> _entrarNaFila() async {
    final sucesso = await _viewModel.entrarNaFila();

    if (sucesso && mounted) {
      if (_viewModel.hasError) {
        // Se tem erro, significa que o usuário já está na fila
        // Navega para a tela de fila mesmo assim
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FilaView()),
        );
      } else {
        // Sucesso normal
        _mostrarMensagem(
          'Você entrou na fila na posição ${_viewModel.proximaPosicao}!',
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FilaView()),
        );
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
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, child) {
              return Column(
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
                  const SizedBox(height: 24),

                  // Informações da fila
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Pessoas na fila:",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "${_viewModel.pessoasNaFila}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Sua posição será:",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "${_viewModel.proximaPosicao}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão de atualizar
                  TextButton.icon(
                    onPressed: _viewModel.carregarInformacoesFila,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text("Atualizar informações"),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botão Entrar na Fila
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _viewModel.isLoading ? null : _entrarNaFila,
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
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }
}
