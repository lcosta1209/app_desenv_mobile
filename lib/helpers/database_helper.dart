import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _initKey = 'database_initialized';
  static const String _collectionName = 'clientDb';

  /// Verifica se é a primeira execução e inicializa o banco se necessário
  Future<void> initializeDatabase() async {
    try {
      print('🔍 Verificando status de inicialização do database...');

      final prefs = await SharedPreferences.getInstance();
      final isInitialized = prefs.getBool(_initKey) ?? false;

      if (!isInitialized) {
        print('🆕 Primeira execução detectada. Inicializando database...');

        // Testar conexão com Firestore primeiro
        final connectionOk = await testFirestoreConnection();
        if (!connectionOk) {
          throw Exception('Falha na conexão com Firestore');
        }

        await _createClientDbCollection();
        await _markAsInitialized();
        print('✅ Database inicializado com sucesso!');

        // Log de informações
        final info = await getInitializationInfo();
        print('📊 Informações de inicialização: $info');
      } else {
        print('✅ Database já inicializado anteriormente.');

        // Verificar se ainda tem acesso à collection
        final accessOk = await verifyCollectionAccess();
        if (!accessOk) {
          print(
            '⚠️  Problemas de acesso à collection. Tentando reinicializar...',
          );
          await forceReinitialize();
        }
      }
    } catch (e) {
      print('❌ Erro ao inicializar database: $e');
      throw Exception('Falha na inicialização do database: $e');
    }
  }

  /// Força a reinicialização do database (útil para desenvolvimento)
  Future<void> forceReinitialize() async {
    try {
      print('🔄 Forçando reinicialização do database...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_initKey);
      await initializeDatabase();
    } catch (e) {
      print('❌ Erro ao forçar reinicialização: $e');
      throw Exception('Falha na reinicialização forçada: $e');
    }
  }

  /// Cria a collection clientDb e configura índices necessários
  Future<void> _createClientDbCollection() async {
    try {
      // Verificar se a collection já existe
      final collectionRef = _firestore.collection(_collectionName);
      final snapshot = await collectionRef.limit(1).get();

      if (snapshot.docs.isEmpty) {
        // Criar documento dummy para inicializar a collection
        final dummyDoc = await collectionRef.add({
          'nome': 'Cliente Demo',
          'email': 'demo@exemplo.com',
          'cpf': '00000000000',
          'isDummy': true,
          'criadoEm': FieldValue.serverTimestamp(),
          'atualizadoEm': FieldValue.serverTimestamp(),
        });

        print(
          '📄 Collection clientDb criada com documento demo: ${dummyDoc.id}',
        );

        // Remover documento dummy após criação (opcional)
        await dummyDoc.delete();
        print('🗑️ Documento demo removido.');
      } else {
        print('📄 Collection clientDb já existe.');
      }

      // Configurar regras de segurança (informativa)
      await _logSecurityRulesInfo();
    } catch (e) {
      print('❌ Erro ao criar collection clientDb: $e');
      throw Exception('Falha na criação da collection: $e');
    }
  }

  /// Marca o database como inicializado
  Future<void> _markAsInitialized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_initKey, true);
      await prefs.setString(
        'database_init_date',
        DateTime.now().toIso8601String(),
      );
      print('✅ Database marcado como inicializado.');
    } catch (e) {
      print('❌ Erro ao marcar database como inicializado: $e');
    }
  }

  /// Logs informativos sobre regras de segurança
  Future<void> _logSecurityRulesInfo() async {
    print('''
🔒 IMPORTANTE: Configure as regras de segurança no Firebase Console:

OPÇÃO 1 - Para desenvolvimento (mais permissiva):
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Regras para collection clientDb - MODO DESENVOLVIMENTO
    match /clientDb/{document} {
      allow read, write: if true;  // Permite acesso total temporariamente
    }
  }
}

OPÇÃO 2 - Para produção (recomendada):
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Regras para collection clientDb
    match /clientDb/{document} {
      allow read, write: if request.auth != null;
    }
  }
}

⚠️  ATENÇÃO: Use OPÇÃO 1 apenas durante desenvolvimento. 
    Para produção, sempre use OPÇÃO 2 com autenticação.

📝 Configurar em: Firebase Console > Firestore Database > Rules
''');
  }

  /// Verifica o status de inicialização
  Future<bool> isDatabaseInitialized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_initKey) ?? false;
    } catch (e) {
      print('❌ Erro ao verificar status de inicialização: $e');
      return false;
    }
  }

  /// Obtém informações sobre a inicialização
  Future<Map<String, dynamic>> getInitializationInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isInitialized = prefs.getBool(_initKey) ?? false;
      final initDate = prefs.getString('database_init_date');

      return {
        'isInitialized': isInitialized,
        'initDate': initDate,
        'collectionName': _collectionName,
      };
    } catch (e) {
      print('❌ Erro ao obter informações de inicialização: $e');
      return {
        'isInitialized': false,
        'initDate': null,
        'collectionName': _collectionName,
        'error': e.toString(),
      };
    }
  }

  /// Testa a conexão com o Firestore
  Future<bool> testFirestoreConnection() async {
    try {
      await _firestore.collection('test').limit(1).get();
      print('✅ Conexão com Firestore funcionando.');
      return true;
    } catch (e) {
      print('❌ Erro na conexão com Firestore: $e');
      return false;
    }
  }

  /// Limpa dados de inicialização (para desenvolvimento)
  Future<void> resetInitialization() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_initKey);
      await prefs.remove('database_init_date');
      print('🔄 Dados de inicialização resetados.');
    } catch (e) {
      print('❌ Erro ao resetar inicialização: $e');
    }
  }

  /// Verifica se a collection existe e está acessível
  Future<bool> verifyCollectionAccess() async {
    try {
      final collectionRef = _firestore.collection(_collectionName);
      await collectionRef.limit(1).get();
      print('✅ Collection $_collectionName é acessível.');
      return true;
    } catch (e) {
      print('❌ Erro ao acessar collection $_collectionName: $e');
      return false;
    }
  }

  /// Testa especificamente as permissões de leitura e escrita
  Future<Map<String, bool>> testFirestorePermissions() async {
    final result = {'canRead': false, 'canWrite': false, 'canDelete': false};

    // Testar leitura
    try {
      await _firestore.collection(_collectionName).limit(1).get();
      result['canRead'] = true;
      print('✅ Permissão de leitura: OK');
    } catch (e) {
      print('❌ Permissão de leitura: NEGADA - $e');
    }

    // Testar escrita
    try {
      final testDoc = await _firestore.collection(_collectionName).add({
        'teste': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      result['canWrite'] = true;
      print('✅ Permissão de escrita: OK');

      // Testar exclusão
      try {
        await testDoc.delete();
        result['canDelete'] = true;
        print('✅ Permissão de exclusão: OK');
      } catch (e) {
        print('❌ Permissão de exclusão: NEGADA - $e');
      }
    } catch (e) {
      print('❌ Permissão de escrita: NEGADA - $e');
    }

    return result;
  }
}
