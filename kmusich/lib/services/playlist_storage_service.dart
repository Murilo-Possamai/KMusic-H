import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/saved_playlist.dart';

/// Persistência das playlists salvas (com km alvo) em SQLite.
class PlaylistStorageService {
  static const _dbName = 'kmusich.db';
  static const _table = 'saved_playlists';

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = p.join(await getDatabasesPath(), _dbName);
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            uri TEXT NOT NULL,
            imageUrl TEXT,
            targetKmh INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<SavedPlaylist>> getAll() async {
    final db = await _database;
    final rows = await db.query(_table, orderBy: 'targetKmh ASC');
    return rows.map(SavedPlaylist.fromMap).toList();
  }

  /// Insere ou substitui (mesma playlist salva de novo atualiza o km).
  Future<void> insert(SavedPlaylist playlist) async {
    final db = await _database;
    await db.insert(
      _table,
      playlist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateKm(String id, int targetKmh) async {
    final db = await _database;
    await db.update(
      _table,
      {'targetKmh': targetKmh},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
