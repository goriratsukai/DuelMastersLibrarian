class Deck {
  final String deckId;
  String? keyCard1;
  String? keyCard2;
  String? keyCard3;
  String? keyCard4;
  final String deckName;
  String? deckFormat;
  String? deckLevel;
  final int deckCountMain;
  final int deckCountGr;
  final int deckCountUb;
  final DateTime createdAt;
  final DateTime updatedAt;

  Deck({
    required this.deckId,
    this.keyCard1,
    this.keyCard2,
    this.keyCard3,
    this.keyCard4,
    required this.deckName,
    this.deckFormat,
    this.deckLevel,
    required this.deckCountMain,
    required this.deckCountGr,
    required this.deckCountUb,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'deck_id': deckId,
      'key_card1': keyCard1,
      'key_card2': keyCard2,
      'key_card3': keyCard3,
      'key_card4': keyCard4,
      'deck_name': deckName,
      'deck_format': deckFormat,
      'deck_level': deckLevel,
      'deck_count_main': deckCountMain,
      'deck_count_gr': deckCountGr,
      'deck_count_ub': deckCountUb,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      deckId: map['deck_id'],
      keyCard1: map['key_card1'],
      keyCard2: map['key_card2'],
      keyCard3: map['key_card3'],
      keyCard4: map['key_card4'],
      deckName: map['deck_name'],
      deckFormat: map['deck_format'],
      deckLevel: map['deck_level'],
      deckCountMain: map['deck_count_main'],
      deckCountGr: map['deck_count_gr'],
      deckCountUb: map['deck_count_ub'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
