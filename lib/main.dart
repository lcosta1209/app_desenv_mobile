import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/views.dart';
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
        '/': (context) => const LoginView(),
        '/cadastro': (context) => const CadastroView(),
        '/menu': (context) => const MenuView(),
        '/fila': (context) => const FilaView(),
        '/atendimento': (context) => const NovoAtendimentoView(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
