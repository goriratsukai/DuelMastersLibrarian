import 'package:riverpod/riverpod.dart';

import '../source/card_data.dart';

// NotifierProviderで管理するProvider
final buildDeckProvider = NotifierProvider<BuildDeckNotifier, List<SearchCard>>(BuildDeckNotifier.new);

// Notifier本体
class BuildDeckNotifier extends Notifier<List<SearchCard>> {
  @override
  List<SearchCard> build() {
    return []; //初期化
  }

  SearchCard getDeck(int index) {
    return state[index];
  }

  int addDeck(SearchCard card) {
    // デッキの上限は60枚
    if (state.length == 60) {
      print('デッキの上限に達しました');
      return 2;
    }

    // デッキに入っている同じobject_idのカード枚数を数える
    final count = state.where((c) => c.object_id == card.object_id).length;
    // カードが4枚未満の場合のみ追加
    if(count < 4){
      state = [...state, card];
      // 成功したときは0を返す
      print('カードを追加しました');
      return 0;
    }else{
      // 失敗したときは1を返す
      print('カードが4枚あります');
      return 1;
    }
  }

  void removeDeck(int index) {
    final newList = List<SearchCard>.from(state);

    // List.removeでカードを削除
    newList.removeAt(index);
    state = newList;
  }

  void saveDeck(){

  }

  void resetDeck() {
    state = [];
  }

  // 枚数順で並び替える
  void sortDeck() {
    if(state.isEmpty){
      return;
    }

    // object_idごとの数を集計
    final counts = <int, int>{};
    for (final card in state){
      counts[card.object_id] = (counts[card.object_id] ?? 0) + 1;
    }
    // ソート処理
    final sortedList = List<SearchCard>.from(state);
    sortedList.sort((a, b){
      final countA = counts[a.object_id]!;
      final countB = counts[b.object_id]!;
      final countCompare = countB.compareTo(countA);
      if(countCompare != 0){
        return countCompare;
      }
      return a.object_id.compareTo(b.object_id);
    });

    state = sortedList;
  }



  // デッキのカードを入れ替える
  void swapCards(int index1, int index2) {
    final temp = state[index1];
    state[index1] = state[index2];
    state[index2] = temp;

    state = List.from(state);
  }
}