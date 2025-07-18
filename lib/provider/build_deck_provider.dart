import 'package:fluttertoast/fluttertoast.dart';
import 'package:riverpod/riverpod.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../helper/cardData_helper.dart';
import '../helper/database_helper.dart';
import '../model/deck.dart';
import '../source/card_data.dart';

// デッキの種類を定義するenum
enum DeckType {
  main,
  gr,
  uberDimension,
  beginning,
}

// 3つのデッキ（メイン、GR、超次元）の状態を管理するクラス
@immutable
class DeckState {
  const DeckState({
    this.deckID = '',
    this.mainDeck = const [],
    this.grDeck = const [],
    this.uberDimensionDeck = const [],
    this.beginning = const[],
    this.deckName = '',
    this.deckFormat = '',
    this.deckLevel = '',
    this.createdAt = ''
  });

  final String deckID;
  final List<SearchCard> mainDeck;
  final List<SearchCard> grDeck;
  final List<SearchCard> uberDimensionDeck;
  final List<SearchCard> beginning;
  final String deckName;
  final String deckFormat;
  final String deckLevel;
  final String createdAt;

  DeckState copyWith({
    String? deckID,
    List<SearchCard>? mainDeck,
    List<SearchCard>? grDeck,
    List<SearchCard>? uberDimensionDeck,
    List<SearchCard>? beginning,
    String? deckName,
    String? deckFormat,
    String? deckLevel,
    String? createdAt,
  }) {
    return DeckState(
      deckID: deckID ?? this.deckID,
      mainDeck: mainDeck ?? this.mainDeck,
      grDeck: grDeck ?? this.grDeck,
      uberDimensionDeck: uberDimensionDeck ?? this.uberDimensionDeck,
      beginning: beginning ?? this.beginning,
      deckName: deckName ?? this.deckName,
      deckFormat: deckFormat ?? this.deckFormat,
      deckLevel: deckLevel ?? this.deckLevel,
      createdAt: createdAt ?? this.createdAt,
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
      case 3:
        return state.beginning[index];
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
        case 3:
        return addBeginingDeck(card);
    }
    throw Exception('Invalid belong_deck value: ${card.belong_deck}');
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
      case 3:
        removeBeginingDeck(index);
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
    // 殿堂入りチェック
    if(card.premium_fame_flag == 1){
      // プレミアム殿堂カードは0枚まで
      if(count >= 0){
        Fluttertoast.showToast(msg: '殿堂ルールの上限より多くデッキに入っています\n${card.card_name}');
      }
    }
    if(card.fame_flag == 1){
      // 殿堂カードは1枚まで
      if(count >= 1){
        Fluttertoast.showToast(msg: '殿堂ルールの上限より多くデッキに入っています\n${card.card_name}');
      }
    }
    // カードがカードごとの上限より少ないときだけ追加
    if(count < card.max_count){
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
    // 殿堂入りチェック
    if(card.premium_fame_flag == 1){
      // プレミアム殿堂カードは0枚まで
      if(count >= 0){
        Fluttertoast.showToast(msg: '殿堂ルールの上限より多くデッキに入っています\n${card.card_name}');
      }
    }
    if(card.fame_flag == 1){
      // 殿堂カードは1枚まで
      if(count >= 1){
        Fluttertoast.showToast(msg: '殿堂ルールの上限より多くデッキに入っています\n${card.card_name}');
      }
    }
    if(count < card.max_count){
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
    // 殿堂入りチェック
    if(card.premium_fame_flag == 1){
      // プレミアム殿堂カードは0枚まで
      if(count >= 0){
        Fluttertoast.showToast(msg: '殿堂ルールの上限より多くデッキに入っています\n${card.card_name}');
      }
    }
    if(card.fame_flag == 1){
      // 殿堂カードは1枚まで
      if(count >= 1){
        Fluttertoast.showToast(msg: '殿堂ルールの上限より多くデッキに入っています\n${card.card_name}');
      }
    }
    if(count < card.max_count){
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

  // ----ゲーム開始時にバトルゾーンに存在できるカード----

  /// カードを追加する
  /// 戻り値: 0 = 成功, 6 = 1枚制限
  int addBeginingDeck(SearchCard card){
    // 上限は1枚
    if(state.beginning.length >= 1){
      return 1;
    }
    state = state.copyWith(beginning: [...state.beginning, card]);
    return 0;
  }

  /// カードを削除する
  void removeBeginingDeck(int index){
    final newList = List<SearchCard>.from(state.beginning);
    newList.removeAt(index);
    state = state.copyWith(beginning: newList);
  }

  /// リセットする
  void resetBeginingDeck(){
    state = state.copyWith(beginning: []);
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
      case DeckType.beginning:
        return;
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
      case DeckType.beginning:
        return;
    }
  }

  // デッキ情報更新
  void updateDeckInfo({String? name, String? format, String? level}) {
    state = state.copyWith(
      deckName: name,
      deckFormat: format,
      deckLevel: level,
    );
  }

  /// デッキ保存
  Future<bool> saveDeck() async {
    try {
      final now = DateTime.now();
      const uuid = Uuid();
      final newDeck = Deck(
        deckId: uuid.v4(),
        deckName: state.deckName,
        deckFormat: state.deckFormat,
        deckLevel: state.deckLevel,
        deckCountMain: state.mainDeck.length,
        deckCountGr: state.grDeck.length,
        deckCountUb: state.uberDimensionDeck.length,
        createdAt: now,
        updatedAt: now,
      );

      await DatabaseHelper.instance.saveDeckTransaction(
        newDeck,
        state.mainDeck,
        state.grDeck,
        state.uberDimensionDeck,
      );
      // 保存成功後にstateを初期化
      state = const DeckState(mainDeck: [], grDeck: [], uberDimensionDeck: []);
      return true;
    } catch (e) {
      // エラーハンドリング
      print('Failed to save deck: $e');
      return false;
    }
  }

  // 既存デッキ更新
  Future<bool> updateDeck() async {
    try {
      final now = DateTime.now();
      final newDeck = Deck(
        deckId: state.deckID,
        deckName: state.deckName,
        deckFormat: state.deckFormat,
        deckLevel: state.deckLevel,
        deckCountMain: state.mainDeck.length,
        deckCountGr: state.grDeck.length,
        deckCountUb: state.uberDimensionDeck.length,
        createdAt: DateTime.parse(state.createdAt),
        updatedAt: now,
      );

      await DatabaseHelper.instance.updateDeckTransaction(
        newDeck,
        state.mainDeck,
        state.grDeck,
        state.uberDimensionDeck,
      );
      // 保存成功後にstateを初期化
      state = const DeckState(mainDeck: [], grDeck: [], uberDimensionDeck: []);
      return true;
    } catch (e) {
      // エラーハンドリング
      print('Failed to save deck: $e');
      return false;
    }

  }

  // デッキを読み込む
  Future<bool> loadSingleDeck(String deckId) async {
    // 読み込む前にリセットする
    resetAllDecks();
    try{
      final List<Map<String, dynamic>> deckInfo = await DatabaseHelper.instance.loadSingleDeckInfo(deckId);
      if(deckInfo.isEmpty){
        return false;
      }
      final deck = Deck.fromMap(deckInfo[0]);
      state = state.copyWith(
        deckID: deck.deckId,
        deckName: deck.deckName,
        deckFormat: deck.deckFormat,
        deckLevel: deck.deckLevel,
        createdAt: deck.createdAt.toString(),
      );
    }catch(e){
      print('Failed to load deck: $e');
      return false;
    }

    try{
      final List<int> physicalIds = await DatabaseHelper.instance.loadSingleDeckPhysicalID(deckId);
      print(physicalIds);
      for(final physicalId in physicalIds){
        print(physicalId);
        final card = await CardDataHelper.instance.getCardDataByPhysicalId(physicalId);
        addDeck(card);
      }
      return true;

    }catch(e){
      print('Failed to load deck: $e');
      return false;
    }
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