import 'package:flutter/material.dart';

import '../source/card_data.dart';

class BuildDeckProvider extends ChangeNotifier {
  List<SearchCard> _deck = [];

  get deck => _deck;

  void addDeck(SearchCard card) {
    _deck.add(card);
    notifyListeners();
  }
  void resetDeck() {
    _deck = [];
    notifyListeners();
  }

}