import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1E3A8A);
  static const Color secondary = Colors.blueAccent;
  static const Color error = Colors.red;
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF5F5F5);
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;
}

class AppStrings {
  // App
  static const String appName = 'ATENDI+';
  static const String appTitle = 'ATENDI';
  static const String appPlus = '+';

  // Auth
  static const String login = 'Entrar';
  static const String register = 'Cadastrar-se';
  static const String logout = 'Sair';
  static const String email = 'Email';
  static const String password = 'Senha';
  static const String emailOrCpf = 'Email ou CPF';
  static const String name = 'Nome completo';
  static const String cpf = 'CPF';
  static const String phone = 'Telefone (opcional)';
  static const String birthDate = 'Data de Nascimento (opcional)';

  // Messages
  static const String loginSuccess = 'Login realizado com sucesso!';
  static const String registerSuccess = 'Cadastro realizado com sucesso!';
  static const String logoutSuccess = 'Logout realizado com sucesso!';
  static const String fillAllFields = 'Por favor, preencha todos os campos.';
  static const String userNotAuthenticated = 'Usuário não autenticado';
  static const String alreadyInQueue = 'Você já está na fila!';
  static const String exitedQueue = 'Você saiu da fila';
  static const String notInQueue = 'Você não está na fila';

  // Queue
  static const String newService = 'Novo Atendimento';
  static const String queue = 'Fila de Atendimento';
  static const String enterQueue = 'Entrar na Fila';
  static const String exitQueue = 'Sair da Fila';
  static const String yourPosition = 'Sua posição será:';
  static const String peopleInQueue = 'Pessoas na fila:';
  static const String estimatedTime = 'Tempo estimado:';
  static const String updateInfo = 'Atualizar informações';
  static const String yourPositionInQueue = 'Sua Posição na Fila';
  static const String confirmExit = 'Tem certeza que deseja sair da fila?';

  // Navigation
  static const String cancel = 'Cancelar';
  static const String confirm = 'Confirmar';
  static const String tryAgain = 'Tentar Novamente';
  static const String back = 'Voltar';

  // Links
  static const String noAccount = 'Não tem uma conta? Cadastrar-se';
  static const String hasAccount = 'Já tem uma conta? Entrar';
}

class AppSizes {
  // Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;

  // Font Sizes
  static const double fontSm = 12.0;
  static const double fontMd = 14.0;
  static const double fontLg = 16.0;
  static const double fontXl = 18.0;
  static const double fontXxl = 22.0;
  static const double fontTitle = 24.0;
  static const double fontLogo = 32.0;
  static const double fontLogoPlus = 36.0;
  static const double fontPosition = 48.0;

  // Icon Sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;
  static const double iconQueue = 80.0;

  // Button Padding
  static const double buttonPaddingVertical = 14.0;
  static const double buttonPaddingLarge = 16.0;

  // Container Padding
  static const double containerPadding = 16.0;
  static const double screenPadding = 30.0;
  static const double screenPaddingVertical = 40.0;
}

class AppDurations {
  static const Duration short = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration long = Duration(seconds: 2);
  static const Duration snackBar = Duration(seconds: 3);
}
