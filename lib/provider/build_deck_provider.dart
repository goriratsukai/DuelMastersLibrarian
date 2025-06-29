import 'package:riverpod/riverpod.dart';
import 'package:meta/meta.dart';

import '../source/card_data.dart';

// デッキの種類を定義するenum
enum DeckType {
  main,
  gr,
  uberDimension,
}

// 3つのデッキ（メイン、GR、超次元）の状態を管理するクラス
@immutable
class DeckState {
  const DeckState({
    this.mainDeck = const [],
    this.grDeck = const [],
    this.uberDimensionDeck = const [],
  });

  final List<SearchCard> mainDeck;
  final List<SearchCard> grDeck;
  final List<SearchCard> uberDimensionDeck;

  DeckState copyWith({
    List<SearchCard>? mainDeck,
    List<SearchCard>? grDeck,
    List<SearchCard>? uberDimensionDeck,
  }) {
    return DeckState(
      mainDeck: mainDeck ?? this.mainDeck,
      grDeck: grDeck ?? this.grDeck,
      uberDimensionDeck: uberDimensionDeck ?? this.uberDimensionDeck,
    );
  }
}


// NotifierProviderで管理するProvider
final buildDeckProvider = NotifierProvider<BuildDeckNotifier, DeckState>(BuildDeckNotifier.new);

// Notifier本体
class BuildDeckNotifier extends Notifier<DeckState> {
  @override
  DeckState build() {
    return const DeckState(); //初期化
  }

  // --- カード取得 ---
  SearchCard getCardFromDeck(SearchCard card, int index) {
    switch (card.belong_deck) {
      case 0:
        return state.mainDeck[index];
      case 1:
        return state.uberDimensionDeck[index];
      case 2:
        return state.grDeck[index];
    }
    throw Exception('Invalid belong_deck value: ${card.belong_deck}');
  }

  // デッキ追加処理を集約
  int addDeck(SearchCard card){
    switch(card.belong_deck){
      case 0:
        return addMainDeck(card);
      case 1:
        return addUberDimensionDeck(card);
      case 2:
        return addGrDeck(card);
      default:
    }
    return 0;
  }

  // デッキ削除処理を集約
  void removeDeck(SearchCard card, int index){
    switch(card.belong_deck){
      case 0:
        removeMainDeck(index);
        break;
      case 1:
        removeUberDimensionDeck(index);
        break;
      case 2:
        removeGrDeck(index);
        break;
    }
  }


  // --- メインデッキ操作 ---

  /// メインデッキにカードを追加する
  /// 戻り値: 0 = 成功, 1 = 同名カード4枚制限, 2 = メインデッキ枚数上限
  int addMainDeck(SearchCard card) {
    // デッキの上限は60枚
    if (state.mainDeck.length >= 60) {
      print('メインデッキの上限に達しました');
      return 2;
    }

    // デッキに入っている同じobject_idのカード枚数を数える
    final count = state.mainDeck.where((c) => c.object_id == card.object_id).length;
    // カードが4枚未満の場合のみ追加
    if(count < 4){
      state = state.copyWith(mainDeck: [...state.mainDeck, card]);
      // 成功したときは0を返す
      print('メインデッキにカードを追加しました');
      return 0; // 成功
    }else{
      // 失敗したときは1を返す
      print('メインデッキに同じカードが既に4枚あります');
      return 1; // 失敗
    }
  }

  /// メインデッキからカードを削除する
  void removeMainDeck(int index) {
    final newList = List<SearchCard>.from(state.mainDeck);
    newList.removeAt(index);
    state = state.copyWith(mainDeck: newList);
  }

  /// メインデッキをリセットする
  void resetMainDeck() {
    state = state.copyWith(mainDeck: []);
  }

  /// メインデッキをソートする
  void sortMainDeck() {
    state = state.copyWith(mainDeck: _sortDeck(state.mainDeck));
  }


  // --- GRデッキ操作 ---

  /// GRデッキにカードを追加する
  /// 戻り値: 0 = 成功, 3 = 同名カード2枚制限, 4 = GRデッキ枚数上限
  int addGrDeck(SearchCard card) {
    // デッキの上限は12枚
    if (state.grDeck.length >= 12) {
      print('GRデッキの上限に達しました');
      return 4;
    }

    final count = state.grDeck.where((c) => c.object_id == card.object_id).length;
    if(count < 2){
      state = state.copyWith(grDeck: [...state.grDeck, card]);
      print('GRデッキにカードを追加しました');
      return 0;
    }else{
      print('GRデッキに同じカードが既に2枚あります');
      return 3;
    }
  }

  /// GRデッキからカードを削除する
  void removeGrDeck(int index) {
    final newList = List<SearchCard>.from(state.grDeck);
    newList.removeAt(index);
    state = state.copyWith(grDeck: newList);
  }

  /// GRデッキをリセットする
  void resetGrDeck() {
    state = state.copyWith(grDeck: []);
  }

  /// GRデッキをソートする
  void sortGrDeck() {
    state = state.copyWith(grDeck: _sortDeck(state.grDeck));
  }


  // --- 超次元デッキ操作 ---

  /// 超次元デッキにカードを追加する
  /// 戻り値: 0 = 成功, 1 = 同名カード4枚制限, 5 = 超次元デッキ枚数上限
  int addUberDimensionDeck(SearchCard card) {
    // デッキの上限は8枚
    if (state.uberDimensionDeck.length >= 8) {
      print('超次元デッキの上限に達しました');
      return 5;
    }
    final count = state.uberDimensionDeck.where((c) => c.object_id == card.object_id).length;
    if(count < 4){
      state = state.copyWith(uberDimensionDeck: [...state.uberDimensionDeck, card]);
      print('超次元デッキにカードを追加しました');
      return 0;
    }else{
      print('超次元デッキに同じカードが既に4枚あります');
      return 1;
    }
  }

  /// 超次元デッキからカードを削除する
  void removeUberDimensionDeck(int index) {
    final newList = List<SearchCard>.from(state.uberDimensionDeck);
    newList.removeAt(index);
    state = state.copyWith(uberDimensionDeck: newList);
  }

  /// 超次元デッキをリセットする
  void resetUberDimensionDeck() {
    state = state.copyWith(uberDimensionDeck: []);
  }

  /// 超次元デッキをソートする
  void sortUberDimensionDeck() {
    state = state.copyWith(uberDimensionDeck: _sortDeck(state.uberDimensionDeck));
  }


  // --- 共通・その他 ---

  /// 全てのデッキをリセットする
  void resetAllDecks() {
    state = const DeckState();
  }

  /// デッキのカードを入れ替える
  void swapCards(DeckType deckType, int index1, int index2) {
    final List<SearchCard> targetDeck;
    switch (deckType) {
      case DeckType.main:
        targetDeck = state.mainDeck;
        break;
      case DeckType.gr:
        targetDeck = state.grDeck;
        break;
      case DeckType.uberDimension:
        targetDeck = state.uberDimensionDeck;
        break;
    }
    // インデックスの範囲チェック
    if (index1 < 0 || index1 >= targetDeck.length || index2 < 0 || index2 >= targetDeck.length) {
      return;
    }
    final newList = List<SearchCard>.from(targetDeck);

    final temp = newList[index1];
    newList[index1] = newList[index2];
    newList[index2] = temp;

    switch (deckType) {
      case DeckType.main:
        state = state.copyWith(mainDeck: newList);
        break;
      case DeckType.gr:
        state = state.copyWith(grDeck: newList);
        break;
      case DeckType.uberDimension:
        state = state.copyWith(uberDimensionDeck: newList);
        break;
    }
  }

  void saveDeck(){
    // 未実装
  }

  // 内部的なソート処理（枚数順 -> object_id順）
  List<SearchCard> _sortDeck(List<SearchCard> deck) {
    if(deck.isEmpty){
      return deck;
    }

    // object_idごとの数を集計
    final counts = <int, int>{};
    for (final card in deck){
      counts[card.object_id] = (counts[card.object_id] ?? 0) + 1;
    }
    // ソート処理
    final sortedList = List<SearchCard>.from(deck);
    sortedList.sort((a, b){
      final countA = counts[a.object_id]!;
      final countB = counts[b.object_id]!;
      final countCompare = countB.compareTo(countA);
      if(countCompare != 0){
        return countCompare;
      }
      return a.object_id.compareTo(b.object_id);
    });

    return sortedList;
  }
}