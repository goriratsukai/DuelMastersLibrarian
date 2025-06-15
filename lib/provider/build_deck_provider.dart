import 'package:flutter/material.dart';
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

  void addDeck(SearchCard card) {
    state = [...state, card];
  }

  void resetDeck() {
    state = [];
  }
}