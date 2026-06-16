import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/analysis_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('olive_oil_analyzer.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Initialiser sqflite_common_ffi pour desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String dbPath = join(appDocDir.path, filePath);

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Créer la table analyses
    await db.execute('''
      CREATE TABLE analyses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code_echantillon TEXT NOT NULL UNIQUE,
        nom_client TEXT NOT NULL,
        code_client TEXT NOT NULL,
        quantite_huile TEXT,
        date_reception TEXT NOT NULL,
        date_analyse TEXT NOT NULL,
        acidite_libre REAL NOT NULL,
        masse_k232 REAL NOT NULL,
        absorbance_232 REAL NOT NULL,
        masse_k270 REAL NOT NULL,
        absorbance_270 REAL NOT NULL,
        absorbance_274 REAL NOT NULL,
        absorbance_266 REAL NOT NULL,
        k232_calcule REAL NOT NULL,
        k270_calcule REAL NOT NULL,
        k274_calcule REAL NOT NULL,
        k266_calcule REAL NOT NULL,
        delta_k_calcule REAL NOT NULL,
        conforme INTEGER NOT NULL,
        date_creation TEXT NOT NULL,
        chemin_pdf TEXT
      )
    ''');

    // Créer les index
    await db.execute(
      'CREATE INDEX idx_code_echantillon ON analyses(code_echantillon)'
    );
    await db.execute(
      'CREATE INDEX idx_nom_client ON analyses(nom_client)'
    );
    await db.execute(
      'CREATE INDEX idx_date_analyse ON analyses(date_analyse)'
    );

    // Créer la table configuration
    await db.execute('''
      CREATE TABLE configuration (
        cle TEXT PRIMARY KEY,
        valeur TEXT
      )
    ''');

    // Insérer les valeurs de configuration par défaut
    await db.insert('configuration', {'cle': 'nom_entreprise', 'valeur': 'MENANA ORGANIC FOOD'});
    await db.insert('configuration', {'cle': 'ville', 'valeur': 'Sousse'});
    await db.insert('configuration', {'cle': 'mf', 'valeur': '1830790TNM000'});
    await db.insert('configuration', {'cle': 'limite_acidite', 'valeur': '0.8'});
    await db.insert('configuration', {'cle': 'limite_k232', 'valeur': '2.50'});
    await db.insert('configuration', {'cle': 'limite_k270', 'valeur': '0.22'});
    await db.insert('configuration', {'cle': 'limite_delta_k', 'valeur': '0.01'});
  }

  // CRUD Operations

  /// Créer une nouvelle analyse
  Future<int> createAnalysis(Analysis analysis) async {
    final db = await database;
    return await db.insert('analyses', analysis.toMap());
  }

  /// Lire une analyse par ID
  Future<Analysis?> readAnalysis(int id) async {
    final db = await database;
    final maps = await db.query(
      'analyses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Analysis.fromMap(maps.first);
    }
    return null;
  }

  /// Lire toutes les analyses
  Future<List<Analysis>> readAllAnalyses() async {
    final db = await database;
    const orderBy = 'date_analyse DESC';
    final result = await db.query('analyses', orderBy: orderBy);
    return result.map((map) => Analysis.fromMap(map)).toList();
  }

  /// Rechercher des analyses
  Future<List<Analysis>> searchAnalyses(String query) async {
    final db = await database;
    final result = await db.query(
      'analyses',
      where: 'code_echantillon LIKE ? OR nom_client LIKE ? OR code_client LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'date_analyse DESC',
    );
    return result.map((map) => Analysis.fromMap(map)).toList();
  }

  /// Lire les analyses par plage de dates
  Future<List<Analysis>> readAnalysesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final result = await db.query(
      'analyses',
      where: 'date_analyse BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date_analyse DESC',
    );
    return result.map((map) => Analysis.fromMap(map)).toList();
  }

  /// Mettre à jour une analyse
  Future<int> updateAnalysis(Analysis analysis) async {
    final db = await database;
    return await db.update(
      'analyses',
      analysis.toMap(),
      where: 'id = ?',
      whereArgs: [analysis.id],
    );
  }

  /// Supprimer une analyse
  Future<int> deleteAnalysis(int id) async {
    final db = await database;
    return await db.delete(
      'analyses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Obtenir les statistiques
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    // Total analyses
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM analyses');
    final total = totalResult.first['count'] as int;
    
    // Analyses conformes
    final conformesResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM analyses WHERE conforme = 1'
    );
    final conformes = conformesResult.first['count'] as int;
    
    // Dernière analyse
    final lastResult = await db.query(
      'analyses',
      orderBy: 'date_analyse DESC',
      limit: 1,
    );
    
    DateTime? lastAnalysisDate;
    if (lastResult.isNotEmpty) {
      lastAnalysisDate = DateTime.parse(lastResult.first['date_analyse'] as String);
    }
    
    return {
      'total': total,
      'conformes': conformes,
      'nonConformes': total - conformes,
      'tauxConformite': total > 0 ? (conformes / total * 100).toStringAsFixed(1) : '0',
      'lastAnalysisDate': lastAnalysisDate,
    };
  }

  /// Vérifier si un code échantillon existe déjà
  Future<bool> codeEchantillonExists(String codeEchantillon, {int? excludeId}) async {
    final db = await database;
    String whereClause = 'code_echantillon = ?';
    List<dynamic> whereArgs = [codeEchantillon];
    
    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }
    
    final result = await db.query(
      'analyses',
      where: whereClause,
      whereArgs: whereArgs,
    );
    
    return result.isNotEmpty;
  }

  /// Lire une configuration
  Future<String?> getConfig(String key) async {
    final db = await database;
    final result = await db.query(
      'configuration',
      where: 'cle = ?',
      whereArgs: [key],
    );
    
    if (result.isNotEmpty) {
      return result.first['valeur'] as String?;
    }
    return null;
  }

  /// Mettre à jour une configuration
  Future<void> setConfig(String key, String value) async {
    final db = await database;
    await db.insert(
      'configuration',
      {'cle': key, 'valeur': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fermer la base de données
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}