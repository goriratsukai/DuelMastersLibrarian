import 'package:dml/provider/search_param_provider.dart';
import 'package:flutter/material.dart';
import 'package:dml/source/card_data.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

double deviceHeight = 0.0;
double deviceWidth = 0.0;

class SearchResultsProvider extends ChangeNotifier {
  // 1ページに表示する枚数
  int _page_coun = 60;

  // 検索結果を入れる配列
  List<SearchCard> _results = [];
  int _length = 0;
  // 検索結果を表示する時のページ添え字
  int _page_num = 1;
  // 検索結果のページ換算数
  int _page_count = 0;
  // 検索結果を表示する時の列数
  int _displayColumn = 2;

  // getter
  List<SearchCard> get results => _results;
  int get length => _length;

  int get page_coun => _page_coun;
  int get page_num => _page_num;
  int get page_count => _page_count;

  int get displayColumn => _displayColumn;

  // setter
  void setDisplayColumn(int column) {
    // 表示列を変更して通知
    _displayColumn = column;
    notifyListeners();
  }

  void resetAll(){
    // 何か増えたら追加する
    notifyListeners();
  }

  void setResults(List<Map<String, dynamic>> results) {
    _results = List.generate(results.length, (i) {
      final row = results[i];
      return SearchCard(
        object_id: row['object_id'],
        card_name: row['card_name'],
        image_name: row['image_name'],
      );
    });
    _length = _results.length;

    print('Query result: $_results');
    print('Query count: $_length');

    notifyListeners();
  }


  Future<Database> openLocalDatabase() async {
    final databasesPath = await getApplicationDocumentsDirectory();
    final path = join(databasesPath.path, 'card_data.db');
    return openDatabase(path);
  }
  Future<void> search_name(SearchParamProvider spm) async {
    String querySelect = spm.getQuery();

    final database = await openLocalDatabase();

    final Database db = database;
    final List<Map<String, dynamic>> queryResults =
    await db.rawQuery(querySelect);
    print('Query result: $queryResults');
    print('Query: ' + querySelect.replaceAll(RegExp(r'\n'), ' '));

    _results = List.generate(queryResults.length, (i) {
      return SearchCard(
        object_id: queryResults[i]['object_id'],
        card_name: queryResults[i]['card_name'],
        image_name: queryResults[i]['image_name'],
      );
    });
    _length = _results.length;
    notifyListeners();
  }
}
