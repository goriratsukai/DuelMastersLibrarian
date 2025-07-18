class SearchCard {
  final int object_id;
  final String card_name;
  final String image_name;
  final int belong_deck;
  final int physical_id;
  final int max_count;
  final int premium_fame_flag;
  final int fame_flag;
  final int combination_fame_group;

  SearchCard({
    required this.object_id,
    required this.card_name,
    required this.image_name,
    required this.belong_deck,
    required this.physical_id,
    required this.max_count,
    required this.premium_fame_flag,
    required this.fame_flag,
    required this.combination_fame_group,
  });
}