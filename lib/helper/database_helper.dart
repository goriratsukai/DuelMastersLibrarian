import 'dart:async';
import 'package:dml/model/deck.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dml/source/card_data.dart';

class DatabaseHelper {
  // シングルトンインスタンス
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // データベースへのアクセサ
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // データベースの初期化
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'deck_list.db');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // テーブルの作成
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE decks (
        deck_id TEXT PRIMARY KEY,
        key_card1 TEXT,
        key_card2 TEXT,
        key_card3 TEXT,
        key_card4 TEXT,
        deck_name TEXT NOT NULL,
        deck_format TEXT,
        deck_level TEXT,
        deck_count_main INTEGER NOT NULL,
        deck_count_gr INTEGER NOT NULL,
        deck_count_ub INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE deck_card (
        deck_id TEXT,
        belong_deck INTEGER,
        deck_index INTEGER,
        physical_id INTEGER,
        image_name TEXT,
        PRIMARY KEY(deck_id, belong_deck, deck_index)
      );
    ''');
  }

  // デッキを保存する（トランザクション処理）
  Future<void> saveDeckTransaction(Deck newDeck, List<SearchCard> mainDeck, List<SearchCard> grDeck, List<SearchCard> uberDimensionDeck) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // decksテーブルへの挿入
      await txn.insert('decks', newDeck.toMap());

      // deck_cardテーブルへの挿入
      final batch = txn.batch();

      // メインデッキ
      for (int i = 0; i < mainDeck.length; i++) {
        batch.insert('deck_card', {
          'deck_id': newDeck.deckId,
          'belong_deck': 0, // mainDeck
          'deck_index': i,
          'physical_id': mainDeck[i].physical_id,
          'image_name': mainDeck[i].image_name,
        });
      }
      // GRデッキ
      for (int i = 0; i < grDeck.length; i++) {
        batch.insert('deck_card', {
          'deck_id': newDeck.deckId,
          'belong_deck': 1, // GrDeck
          'deck_index': i,
          'physical_id': grDeck[i].physical_id,
          'image_name': grDeck[i].image_name,
        });
      }
      // 超次元ゾーン
      for (int i = 0; i < uberDimensionDeck.length; i++) {
        batch.insert('deck_card', {
          'deck_id': newDeck.deckId,
          'belong_deck': 2, // UberDimensionDeck
          'deck_index': i,
          'physical_id': uberDimensionDeck[i].physical_id,
          'image_name': uberDimensionDeck[i].image_name,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  // すべてのデッキを取得する
  Future<List<Deck>> getDecks() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('decks', orderBy: 'updatedAt DESC');

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return Deck.fromMap(maps[i]);
    });
  }
}
