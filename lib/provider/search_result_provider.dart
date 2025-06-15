import 'package:dml/provider/search_param_provider.dart';
import 'package:flutter/material.dart';
import 'package:dml/source/card_data.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:riverpod/riverpod.dart';

class SearchResultsNotifier extends AsyncNotifier<List<SearchCard>> {
  // データベースのセッション保持変数
  Database? _database;

  @override
  Future<List<SearchCard>> build() async {
    // ref.watchでProviderを関しする。searchParamProviderの状態が変わると
    // このbuildメソッドが自動で再実行されて検索結果が更新される
    final searchParam = ref.watch(searchParamProvider);
    final query = ref.read(searchParamProvider.notifier).getQuery();

    final database = await openLocalDatabase();
    final List<Map<String, dynamic>> queryResults = await database.rawQuery(query);

    return List.generate(queryResults.length, (i) {
      return SearchCard(
        object_id: queryResults[i]['object_id'],
        card_name: queryResults[i]['card_name'],
        image_name: queryResults[i]['image_name'],
      );
    });
  }
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
}
// Provider
final searchResultsProvider = AsyncNotifierProvider<SearchResultsNotifier, List<SearchCard>>(SearchResultsNotifier.new);

class DisplayColumnNotifier extends Notifier<int>{
  @override
  int build() {
    return 2;
  }
}
final displayColumnProvider = NotifierProvider<DisplayColumnNotifier,int>(DisplayColumnNotifier.new);