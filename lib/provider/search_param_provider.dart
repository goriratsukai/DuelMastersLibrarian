import 'package:flutter/material.dart';
import 'package:dml/source/card_data.dart';

class SearchParamProvider extends ChangeNotifier {
  // 文字入力系
  String _name = "";
  String _race = "";
  String _type = "";
  String _text = "";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _raceController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  // 数字系
  String _costMin = '';
  String _costMax = '';
  String _powerMin = '';
  String _powerMax = '';
  final TextEditingController _costMinController = TextEditingController();
  final TextEditingController _costMaxController = TextEditingController();
  final TextEditingController _powerMinController = TextEditingController();
  final TextEditingController _powerMaxController = TextEditingController();

  /* 文明の検索単位
   * 0=>カード、1=>名前
   */
  List<bool> _civilSearchUnit = [true, false];

  /* 文明のセレクター
   * 0=>必須、1=>任意、2=>不要
   */
  List<bool> _civil1 = [false, true, false];
  List<bool> _civil2 = [false, true, false];
  List<bool> _civil3 = [false, true, false];
  List<bool> _civil4 = [false, true, false];
  List<bool> _civil5 = [false, true, false];
  List<bool> _civil6 = [false, true, false];
  bool _checkCivils = false;

  /*
   * 同名カードフラグ
   */
  bool _sameName = true;

  // カード検索用クエリ

  // UI用getter
  get name => _name;

  get race => _race;

  get type => _type;

  get text => _text;

  get nameController => _nameController;

  get raceController => _raceController;

  get typeController => _typeController;

  get textController => _textController;

  get costMin => _costMin;

  get costMax => _costMax;

  get powerMin => _powerMin;

  get powerMax => _powerMax;

  get costMinController => _costMinController;

  get costMaxController => _costMaxController;

  get powerMinController => _powerMinController;

  get powerMaxController => _powerMaxController;

  get checkCivils => _checkCivils;

  get civilSearchUnit => _civilSearchUnit;

  get civil1 => _civil1;

  get civil2 => _civil2;

  get civil3 => _civil3;

  get civil4 => _civil4;

  get civil5 => _civil5;

  get civil6 => _civil6;

  get sameName => _sameName;

  // setter
  void setRace(String race) {
    _race = race;
  }

  void setType(String type) {
    _type = type;
  }

  void setText(String text) {
    _text = text;
  }

  void setName(String name) {
    _name = name;
  }

  void resetName() {
    if (_name != '') {
      _name = '';
      _nameController.text = _name;
      notifyListeners();
    }
  }

  void setCostMin(String cost) {
    _costMin = cost;
  }

  void setCostMax(String cost) {
    _costMax = cost;
  }

  void setPowerMin(String power) {
    _powerMin = power;
  }

  void setPowerMax(String power) {
    _powerMax = power;
  }

  void checkCivilsValid() {
    _checkCivils = _civil1[2] &
        _civil2[2] &
        _civil3[2] &
        _civil4[2] &
        _civil5[2] &
        _civil6[2];
  }

  void setCivilSearchUnit(int index) {
    _civilSearchUnit = [false, false];
    _civilSearchUnit[index] = true;
    notifyListeners();
  }

  void resetCivilAll() {
    _civil1 = [false, true, false];
    _civil2 = [false, true, false];
    _civil3 = [false, true, false];
    _civil4 = [false, true, false];
    _civil5 = [false, true, false];
    _civil6 = [false, true, false];
    _civilSearchUnit = [true, false];
    checkCivilsValid();
    notifyListeners();
  }

  void setCivil1(int index) {
    _civil1 = [false, false, false];
    _civil1[index] = true;
    checkCivilsValid();
    notifyListeners();
  }

  void setCivil2(int index) {
    _civil2 = [false, false, false];
    _civil2[index] = true;
    checkCivilsValid();
    notifyListeners();
  }

  void setCivil3(int index) {
    _civil3 = [false, false, false];
    _civil3[index] = true;
    checkCivilsValid();
    notifyListeners();
  }

  void setCivil4(int index) {
    _civil4 = [false, false, false];
    _civil4[index] = true;
    checkCivilsValid();
    notifyListeners();
  }

  void setCivil5(int index) {
    _civil5 = [false, false, false];
    _civil5[index] = true;
    checkCivilsValid();
    notifyListeners();
  }

  void setCivil6(int index) {
    _civil6 = [false, false, false];
    _civil6[index] = true;
    checkCivilsValid();
    notifyListeners();
  }

  void resetAll() {
    // 検索パラメータを初期化
    // 文字入力系
    _name = '';
    _race = '';
    _type = '';
    _text = '';
    _nameController.text = _name;
    _raceController.text = _race;
    _typeController.text = _type;
    _textController.text = _text;

    // 数字系
    _costMin = '';
    _costMax = '';
    _powerMin = '';
    _powerMax = '';
    _costMinController.text = _costMin;
    _costMaxController.text = _costMax;
    _powerMinController.text = _powerMin;
    _powerMaxController.text = _powerMax;

    /* 文明の検索単位
   * 0=>カード、1=>名前
   */
    _civilSearchUnit = [true, false];

    /* 文明のセレクター
   * 0=>必須、1=>任意、2=>不要
   */
    _civil1 = [false, true, false];
    _civil2 = [false, true, false];
    _civil3 = [false, true, false];
    _civil4 = [false, true, false];
    _civil5 = [false, true, false];
    _civil6 = [false, true, false];
    _checkCivils = false;

    notifyListeners();
  }

  void setSameName(bool sameName) {
    _sameName = sameName;
    notifyListeners();
  }

  // 検索用パラメータ
  String getQuery() {
    if (_name == '今日のカード') {
      String querySelectToday = '''
    select co.object_id object_id, card_name, cp.image_name image_name
    from card_module cm

    join link_object_module lom
    on cm.module_id = lom.module_id

    join card_object co
    on lom.object_id = co.object_id

    join link_module_race lmr
    on lmr.module_id = cm.module_id

    join master_race mr
    on mr.race_id = lmr.race_id

    join card_physical cp
    on co.object_id = cp.object_id

    where (co.object_id % 365) = CAST(STRFTIME('%j', 'now') AS INTEGER)
    group by co.object_id, cp.physical_id
    limit 60;
    ''';
      return querySelectToday;
    }
    String querySelect = '''
    select co.object_id object_id, card_name, cp.image_name image_name
from card_module cm

join link_object_module lom
on cm.module_id = lom.module_id

join card_object co
on lom.object_id = co.object_id

join link_module_race lmr
on lmr.module_id = cm.module_id

join master_race mr
on mr.race_id = lmr.race_id

join ${getSameNameFlag()} cp
on co.object_id = cp.object_id

where cm.card_name like '%${getName()}%'
and   mr.race like '%${getRace()}%'
and   cm.card_type like '%${getType()}%'
and   cm.ability_text like '%${getText()}%'

${getCostMin()}
${getCostMax()}
${getPowerMin()}
${getPowerMax()}

and   ${getCivilSearchUnit()}.civil1 ${getCivil1()}
and   ${getCivilSearchUnit()}.civil2 ${getCivil2()}
and   ${getCivilSearchUnit()}.civil3 ${getCivil3()}
and   ${getCivilSearchUnit()}.civil4 ${getCivil4()}
and   ${getCivilSearchUnit()}.civil5 ${getCivil5()}
and   ${getCivilSearchUnit()}.civil6 ${getCivil6()}

group by co.object_id, cp.physical_id
order by co.object_id desc
;
    ''';
    return querySelect;
  }

  // getter for query
  String getName() {
    // 各文字の間に%を挿入
    List<String> symbols = _name.split('');
    return symbols.join('%');
  }

  String getRace() {
    return _race;
  }

  String getType() {
    return _type;
  }

  String getText() {
    return _text;
  }

  String getCostMin() {
    if (_costMin == '') {
      return 'and cm.cost >= 0';
    } else {
      return 'and   cm.cost >= $_costMin';
    }
  }

  String getCostMax() {
    if (_costMax == '') {
      return 'and cm.cost <= cast(1e999 as real)';
    } else {
      return 'and   cm.cost <= $_costMax';
    }
  }

  String getPowerMin() {
    if (_powerMin == '') {
      return '';
    } else {
      return 'and cm.power >=$_powerMin';
    }
  }

  String getPowerMax() {
    if (_powerMax == '') {
      return '';
    } else {
      return 'and cm.power <= $_powerMax';
    }
  }

  String getSameNameFlag() {
    if (_sameName) {
      return 'card_physical';
    } else {
      return '(select * from card_physical where primary_flag = 1)';
    }
  }

  String getCivil(){
    if(_civil1[0] && _civil2[0] && _civil3[0] && _civil4[0] && _civil5[0] && _civil6[0]){
      return '';
    } else {
      return 'and';
    }
  }

  String getCivil1() {
    if (_civil1[0]) {
      return '=1';
    } else if (_civil1[1]) {
      return 'in (1,0)';
    } else {
      return '=0';
    }
  }

  String getCivil2() {
    if (_civil2[0]) {
      return '=1';
    } else if (_civil2[1]) {
      return 'in (1,0)';
    } else {
      return '=0';
    }
  }

  String getCivil3() {
    if (_civil3[0]) {
      return '=1';
    } else if (_civil3[1]) {
      return 'in (1,0)';
    } else {
      return '=0';
    }
  }

  String getCivil4() {
    if (_civil4[0]) {
      return '=1';
    } else if (_civil4[1]) {
      return 'in (1,0)';
    } else {
      return '=0';
    }
  }

  String getCivil5() {
    if (_civil5[0]) {
      return '=1';
    } else if (_civil5[1]) {
      return 'in (1,0)';
    } else {
      return '=0';
    }
  }

  String getCivil6() {
    if (_civil6[0]) {
      return '=1';
    } else if (_civil6[1]) {
      return 'in (1,0)';
    } else {
      return '=0';
    }
  }

  String getCivilSearchUnit() {
    if (_civilSearchUnit[0]) {
      return 'co';
    } else {
      return 'cm';
    }
  }
}
