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

  // デッキを編集する（トランザクション処理）
  Future<void> updateDeckTransaction(Deck newDeck, List<SearchCard> mainDeck, List<SearchCard> grDeck, List<SearchCard> uberDimensionDeck) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // decksテーブルの更新
      await txn.update('decks', newDeck.toMap(), where: 'deck_id = ?', whereArgs: [newDeck.deckId]);

      // deck_cardテーブルを一旦削除する
      await txn.delete('deck_card', where: 'deck_id = ?', whereArgs: [newDeck.deckId]);

      // deck_cardテーブルに再度挿入
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

  // デッキ読み込み用にデッキデータをロードする関数
  Future<List<Map<String, dynamic>>> loadSingleDeckInfo(String deckId) async {
    final db = await instance.database;
    return await db.query(
      'decks',
      where: 'deck_id = ?',
      whereArgs: [deckId],
    );
  }

  // デッキを削除する
  Future<void> deleteDeck(String deckId) async {
    final db = await instance.database;
    await db.transaction((txn) async{
      await txn.delete('decks', where: 'deck_id = ?', whereArgs: [deckId]);
      await txn.delete('deck_card', where: 'deck_id = ?', whereArgs: [deckId]);
    });
    await db.execute('vacuum');
    await db.execute('reindex');
    await db.execute('analyze');
  }

  // デッキ読み込み用にカードデータをロードする関数
  Future<List<int>> loadSingleDeckPhysicalID(String deckId) async {
    final db = await instance.database;
    // deck_cardテーブルから指定されたdeck_idのレコードを取得
    final List<Map<String, dynamic>> maps = await db.query(
      'deck_card',
      where: 'deck_id = ?',
      whereArgs: [deckId],
      orderBy: 'belong_deck, deck_index', // ゾーンごと、登録順にソート
    );

    // 検索結果が空の場合は空のリストを返す
    if (maps.isEmpty) {
      return [];
    }

    // physical_idのリストを作成して返す
    return List.generate(maps.length, (i) {
      return maps[i]['physical_id'] as int;
    });
  }

  // 画像出力用にデータをロードする関数
  Future<List<Map<String, dynamic>>> getDeckCardsForImage(String deckId) async {
    final db = await instance.database;
    return await db.query(
      'deck_card',
      columns: ['image_name', 'deck_index'],
      where: 'deck_id = ? AND belong_deck = ?',
      whereArgs: [deckId, 0], // belong_deck=0 (メインデッキ) のみ取得
      orderBy: 'deck_index ASC',
    );
  }

  // すべてのデッキヘッダー情報を取得する
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
