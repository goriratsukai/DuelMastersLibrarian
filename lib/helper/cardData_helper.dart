


import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../source/card_data.dart';

class CardDataHelper{
  // シングルトンインスタンス
  CardDataHelper._privateConstructor();
  static final CardDataHelper instance = CardDataHelper._privateConstructor();

  static Database? _database;

  // データベースへのアクセサ
  Future<Database> get database async {
    if(_database != null) return _database!;
    _database = await openLocalDatabase();
    return _database!;
  }

  // データベースに接続
  Future<Database> openLocalDatabase() async {
    // 接続済みの場合は処理なし
    if (_database != null) {
      return _database!;
    }
    final databasesPath = await getApplicationDocumentsDirectory();
    final path = join(databasesPath.path, 'card_data.db');
    _database = await openDatabase(path);
    return _database!;
  }

  // physical_idを受け取ってカードデータを取得
  Future<SearchCard> getCardDataByPhysicalId(int physicalId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> card_data = await db.rawQuery(
      '''
      select co.object_id object_id, cm.card_name card_name, cp.image_name image_name, co.belong_deck belong_deck, cp.physical_id physical_id,
      co.max_count max_count, co.premium_fame_flag premium_fame_flag, co.fame_flag fame_flag, co.combination_fame_group combination_fame_group
      from card_physical cp
      join card_object co
        on cp.object_id = co.object_id
      join link_object_module lom
        on lom.object_id = co.object_id
      join card_module cm
        on cm.module_id = lom.module_id
      where cp.physical_id = $physicalId;
      '''
    );
    return SearchCard(
        object_id: card_data[0]['object_id'],
        card_name: card_data[0]['card_name'],
        image_name: card_data[0]['image_name'],
        belong_deck: card_data[0]['belong_deck'],
        physical_id: card_data[0]['physical_id'],
        max_count: card_data[0]['max_count'],
        premium_fame_flag: card_data[0]['premium_fame_flag'],
        fame_flag: card_data[0]['fame_flag'],
        combination_fame_group: card_data[0]['combination_fame_group'],
      );
  }

}