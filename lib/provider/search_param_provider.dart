import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

@immutable
class SearchParamState {
  const SearchParamState({
    this.name = '',
    this.race = '',
    this.type = '',
    this.text = '',
    this.costMin = '',
    this.costMax = '',
    this.powerMin = '',
    this.powerMax = '',
    this.civilSearchUnit = const [true, false],
    this.civil1 = const [false, true, false],
    this.civil2 = const [false, true, false],
    this.civil3 = const [false, true, false],
    this.civil4 = const [false, true, false],
    this.civil5 = const [false, true, false],
    this.civil6 = const [false, true, false],
    this.checkCivils = false,
    this.sameName = true,
    this.fuzzySearch = true,
    this.sort = 0,
  });

  final String name;
  final String race;
  final String type;
  final String text;
  final String costMin;
  final String costMax;
  final String powerMin;
  final String powerMax;
  final List<bool> civilSearchUnit;
  final List<bool> civil1;
  final List<bool> civil2;
  final List<bool> civil3;
  final List<bool> civil4;
  final List<bool> civil5;
  final List<bool> civil6;
  final bool checkCivils;
  final bool sameName;
  final bool fuzzySearch;
  final int sort;

  SearchParamState copyWith({
    String? name,
    String? race,
    String? type,
    String? text,
    String? costMin,
    String? costMax,
    String? powerMin,
    String? powerMax,
    List<bool>? civilSearchUnit,
    List<bool>? civil1,
    List<bool>? civil2,
    List<bool>? civil3,
    List<bool>? civil4,
    List<bool>? civil5,
    List<bool>? civil6,
    bool? checkCivils,
    bool? sameName,
    bool? fuzzySearch,
    int? sort,
  }) {
    return SearchParamState(
      name: name ?? this.name,
      race: race ?? this.race,
      type: type ?? this.type,
      text: text ?? this.text,
      costMin: costMin ?? this.costMin,
      costMax: costMax ?? this.costMax,
      powerMin: powerMin ?? this.powerMin,
      powerMax: powerMax ?? this.powerMax,
      civilSearchUnit: civilSearchUnit ?? this.civilSearchUnit,
      civil1: civil1 ?? this.civil1,
      civil2: civil2 ?? this.civil2,
      civil3: civil3 ?? this.civil3,
      civil4: civil4 ?? this.civil4,
      civil5: civil5 ?? this.civil5,
      civil6: civil6 ?? this.civil6,
      checkCivils: checkCivils ?? this.checkCivils,
      sameName: sameName ?? this.sameName,
      fuzzySearch: fuzzySearch ?? this.fuzzySearch,
      sort: sort ?? this.sort,
    );
  }
}

// NotifierProviderで管理するProvider
class SearchParamNotifier extends Notifier<SearchParamState> {
  @override
  SearchParamState build() {
    return const SearchParamState(); // 初期状態
  }
  void setName(String name) {
    state = state.copyWith(name: name);
  }
  void setRace(String race) {
    state = state.copyWith(race: race);
  }
  void setType(String type) {
    state = state.copyWith(type: type);
  }
  void setText(String text) {
    state = state.copyWith(text: text);
  }
  void setCostMin(String costMin) {
    state = state.copyWith(costMin: costMin);
  }
  void setCostMax(String costMax) {
    state = state.copyWith(costMax: costMax);
  }
  void setPowerMin(String powerMin) {
    state = state.copyWith(powerMin: powerMin);
  }
  void setPowerMax(String powerMax) {
    state = state.copyWith(powerMax: powerMax);
  }
  void setCivilSearchUnit(int index) {
    if (index == 0 && state.civilSearchUnit[0]) {
      return;
    } else if (index == 1 && state.civilSearchUnit[1]) {
      return;
    }
    state = state.copyWith(civilSearchUnit: [false, false]);
    state.civilSearchUnit[index] = true;
  }

  void resetName(){
    state = state.copyWith(name: '');
  }
  void resetCivilAll() {
    state = state.copyWith(
      civil1: [false, true, false],
      civil2: [false, true, false],
      civil3: [false, true, false],
      civil4: [false, true, false],
      civil5: [false, true, false],
      civil6: [false, true, false]);
  }

  void setCivil1(int index) {
    if (index == 0 && state.civil1[0]) {
      state = state.copyWith(civil1: [false, true, false]);
      return;
    } else if (index == 2 && state.civil1[2]) {
      state = state.copyWith(civil1: [false, true, false]);
      return;
    } else if (index == 1 && state.civil1[1]) {
      return;
    }
    state = state.copyWith(civil1: [false, false, false]);
    state.civil1[index] = true;
  }
  void setCivil2(int index) {
    if (index == 0 && state.civil2[0]) {
      state = state.copyWith(civil2: [false, true, false]);
      return;
    } else if (index == 2 && state.civil2[2]){
      state = state.copyWith(civil2: [false, true, false]);
      return;
    } else if (index == 1 && state.civil2[1]) {
      return;
    }
    state = state.copyWith(civil2: [false, false, false]);
    state.civil2[index] = true;
  }
  void setCivil3(int index) {
    if (index == 0 && state.civil3[0]) {
      state = state.copyWith(civil3: [false, true, false]);
      return;
    } else if (index == 2 && state.civil3[2]) {
      state = state.copyWith(civil3: [false, true, false]);
      return;
    } else if (index == 1 && state.civil3[1]) {
      return;
    }
    state = state.copyWith(civil3: [false, false, false]);
    state.civil3[index] = true;
  }
  void setCivil4(int index) {
    if (index == 0 && state.civil4[0]) {
      state = state.copyWith(civil4: [false, true, false]);
      return;
    } else if (index == 2 && state.civil4[2]) {
      state = state.copyWith(civil4: [false, true, false]);
      return;
    } else if (index == 1 && state.civil4[1]) {
      return;
    }
    state = state.copyWith(civil4: [false, false, false]);
    state.civil4[index] = true;
  }
  void setCivil5(int index) {
    if (index == 0 && state.civil5[0]) {
      state = state.copyWith(civil5: [false, true, false]);
      return;
    } else if (index == 2 && state.civil5[2]) {
      state = state.copyWith(civil5: [false, true, false]);
      return;
    } else if (index == 1 && state.civil5[1]) {
      return;
    }
    state = state.copyWith(civil5: [false, false, false]);
    state.civil5[index] = true;
  }
  void setCivil6(int index) {
    if (index == 0 && state.civil6[0]) {
      state = state.copyWith(civil6: [false, true, false]);
      return;
    } else if (index == 2 && state.civil6[2]) {
      state = state.copyWith(civil6: [false, true, false]);
      return;
    } else if (index == 1 && state.civil6[1]) {
      return;
    }
    state = state.copyWith(civil6: [false, false, false]);
    state.civil6[index] = true;
  }
  void setSameName(bool sameName) {
    state = state.copyWith(sameName: sameName);
  }
  void setFuzzySearch(bool fuzzySearch) {
    state = state.copyWith(fuzzySearch: fuzzySearch);
  }
  void setSort(int sort){
    state = state.copyWith(sort: sort);
  }
  void resetAll() {
    state = const SearchParamState();
  }
  String getQuery() {
    String query = '''
      select card.object_id object_id, card.card_name card_name, cp.image_name image_name
      from (
        select co.object_id object_id, card_name
        from card_module cm
        
        join link_object_module lom
        on cm.module_id = lom.module_id
        
        join card_object co
        on lom.object_id = co.object_id
        
        join link_module_race lmr
        on lmr.module_id = cm.module_id
        
        where cm.card_name like '%${getNameQuery()}%'
        and cm.card_type like '%${getTypeQuery()}%'
        and cm.ability_text like '%${getTextQuery()}%'
        and lmr.race_id in (select race_id from master_race where race like '%${getRaceQuery()}%')
        
        ${getCostMinQuery()}
        ${getCostMaxQuery()}
        ${getPowerMinQuery()}
        ${getPowerMaxQuery()}
        ${getCivil1Query()}
        ${getCivil2Query()}
        ${getCivil3Query()}
        ${getCivil4Query()}
        ${getCivil5Query()}
        ${getCivil6Query()}
        group by co.object_id
        ) card
      join ${getSameNameQuery()} cp
      on card.object_id = cp.object_id
      
      order by card.object_id desc    
    ''';
    return query;
  }

  String getNameQuery(){
    if(state.fuzzySearch) {
      //　あいまい検索が有効なとき、各シンボルの間に%を挿入
      List<String> symbols = state.name.split('');
      return symbols.join('%');
    }
    return state.name;
  }
  String getRaceQuery(){
    return state.race;
  }
  String getTypeQuery(){
    return state.type;
  }
  String getTextQuery(){
    return state.text;
  }
  String getCostMinQuery(){
    if(state.costMin == '') {
      return 'and cm.cost >= 0';
    }else{
      return 'and cm.cost >= ${state.costMin}';
    }
  }
  String getCostMaxQuery() {
    if (state.costMax == '') {
      return 'and cm.cost <= cast(1e999 as real)';
    } else {
      return 'and cm.cost <= ${state.costMax}';
    }
  }
  String getPowerMinQuery() {
    if (state.powerMin == '') {
      return 'and cm.power >= 0';
    } else {
      return 'and cm.power >= ${state.powerMin}';
    }
  }
  String getPowerMaxQuery() {
    if (state.powerMax == '') {
      return 'and cm.power <= cast(1e999 as real)';
    } else {
      return 'and cm.power <= ${state.powerMax}';
    }
  }
  String getSameNameQuery(){
    if(state.sameName) {
      return 'card_physical';
    }else{
      return '(select * from card_physical where primary_flag = 1)';
    }
  }
  String getCivilSearchUnitQuery(){
    if(state.civilSearchUnit[0]){
      return 'co';
    }else{
      return 'cm';
    }
  }
  String getCivil1Query(){
    if(state.civil1[0]){
      return 'and ${getCivilSearchUnitQuery()}.civil1 = 1';
    }else if(state.civil1[1]){
      return '';
    }else if(state.civil1[2]){
      return 'and ${getCivilSearchUnitQuery()}.civil1 = 0';
    }
    return '';
  }
  String getCivil2Query(){
    if(state.civil2[0]){
      return 'and ${getCivilSearchUnitQuery()}.civil2 = 1';
    }else if(state.civil2[1]){
      return '';
    }else if(state.civil2[2]){
      return 'and ${getCivilSearchUnitQuery()}.civil2 = 0';
    }
    return '';
  }
  String getCivil3Query(){
    if(state.civil3[0]){
      return 'and ${getCivilSearchUnitQuery()}.civil3 = 1';
    }else if(state.civil3[1]){
      return '';
    }else if(state.civil3[2]){
      return 'and ${getCivilSearchUnitQuery()}.civil3 = 0';
    }
    return '';
  }
  String getCivil4Query(){
    if(state.civil4[0]){
      return 'and ${getCivilSearchUnitQuery()}.civil4= 1';
    }else if(state.civil4[1]){
      return '';
    }else if(state.civil4[2]){
      return 'and ${getCivilSearchUnitQuery()}.civil4 = 0';
    }
    return '';
  }
  String getCivil5Query(){
    if(state.civil5[0]){
      return 'and ${getCivilSearchUnitQuery()}.civil5 = 1';
    }else if(state.civil5[1]){
      return '';
    }else if(state.civil5[2]){
      return 'and ${getCivilSearchUnitQuery()}.civil5 = 0';
    }
    return '';
  }
  String getCivil6Query(){
    if(state.civil6[0]){
      return 'and ${getCivilSearchUnitQuery()}.civil6 = 1';
    }else if(state.civil6[1]){
      return '';
    }else if(state.civil6[2]){
      return 'and ${getCivilSearchUnitQuery()}.civil6 = 0';
    }
    return '';
  }
}

// Provider
final searchParamProvider = NotifierProvider<SearchParamNotifier, SearchParamState>(SearchParamNotifier.new);