import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    _database ??= await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final appDir = await getApplicationDocumentsDirectory();
    final path = join(appDir.path, 'olive_oil.db');
    return await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE NOT NULL, password TEXT NOT NULL, role TEXT NOT NULL DEFAULT 'user', created_at TEXT NOT NULL)''');
    await db.execute('''CREATE TABLE analyses (id INTEGER PRIMARY KEY AUTOINCREMENT, code_echantillon TEXT NOT NULL UNIQUE, nom_client TEXT NOT NULL, code_client TEXT NOT NULL, quantite_huile TEXT, date_reception TEXT NOT NULL, date_analyse TEXT NOT NULL, acidite_libre REAL NOT NULL, masse_k232 REAL NOT NULL, absorbance_232 REAL NOT NULL, masse_k270 REAL NOT NULL, absorbance_270 REAL NOT NULL, absorbance_274 REAL NOT NULL, absorbance_266 REAL NOT NULL, k232_calcule REAL NOT NULL, k270_calcule REAL NOT NULL, k274_calcule REAL NOT NULL, k266_calcule REAL NOT NULL, delta_k_calcule REAL NOT NULL, conforme INTEGER NOT NULL, date_creation TEXT NOT NULL, chemin_pdf TEXT)''');
    await db.insert('users', {'username': 'admin', 'password': 'admin123', 'role': 'admin', 'created_at': DateTime.now().toIso8601String()});
  }
}
