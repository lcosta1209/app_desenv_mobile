import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';
import 'tela_cadastro.dart';
import 'menu.dart';
import 'tela_fila.dart';
import 'tela_novo_atendimento.dart';
import 'helpers/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Inicializar Database Helper
  try {
    await DatabaseHelper().initializeDatabase();
  } catch (e) {
    print('Erro na inicialização do database: $e');
    // Continua a execução mesmo com erro
  }

  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ATENDI+",
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TelaLogin(),
        '/cadastro': (context) => const TelaCadastro(),
        '/menu': (context) => const TelaMenu(),
        '/fila': (context) => const TelaFila(),
        '/atendimento': (context) => const TelaNovoAtendimento(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
