import 'package:flutter/material.dart';
import 'package:dml/provider/search_param_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

class SearchField extends ConsumerStatefulWidget {
  const SearchField({super.key});

  @override
  ConsumerState<SearchField> createState() => SearchFieldState();
}


class SearchFieldState extends ConsumerState<SearchField> {
  // フォームのコントローラー
  late final TextEditingController _nameController;
  late final TextEditingController _raceController;
  late final TextEditingController _typeController;
  late final TextEditingController _textController;
  late final TextEditingController _costMinController;
  late final TextEditingController _costMaxController;
  late final TextEditingController _powerMinController;
  late final TextEditingController _powerMaxController;

  @override
  void initState(){
    final initialParams = ref.read(searchParamProvider);
    _nameController = TextEditingController(text: initialParams.name);
    _raceController = TextEditingController(text: initialParams.race);
    _typeController = TextEditingController(text: initialParams.type);
    _textController = TextEditingController(text: initialParams.text);
    _costMinController = TextEditingController(text: initialParams.costMin);
    _costMaxController = TextEditingController(text: initialParams.costMax);
    _powerMinController = TextEditingController(text: initialParams.powerMin);
    _powerMaxController = TextEditingController(text: initialParams.powerMax);

    super.initState();
  }


  @override
  void dispose(){
    _nameController.dispose();
    _raceController.dispose();
    _typeController.dispose();
    _textController.dispose();
    _costMinController.dispose();
    _costMaxController.dispose();
    _powerMinController.dispose();
    _powerMaxController.dispose();
    super.dispose();
  }

  final List<PopupMenuItem<String>> _costPopupList = <PopupMenuItem<String>>[
    const PopupMenuItem<String>(value: '', child: Text('コスト無し')),
    const PopupMenuItem<String>(value: '0', child: Text('0')),
    const PopupMenuItem<String>(value: '1', child: Text('1')),
    const PopupMenuItem<String>(value: '2', child: Text('2')),
    const PopupMenuItem<String>(value: '3', child: Text('3')),
    const PopupMenuItem<String>(value: '4', child: Text('4')),
    const PopupMenuItem<String>(value: '5', child: Text('5')),
    const PopupMenuItem<String>(value: '6', child: Text('6')),
    const PopupMenuItem<String>(value: '7', child: Text('7')),
    const PopupMenuItem<String>(value: '8', child: Text('8')),
    const PopupMenuItem<String>(value: '9', child: Text('9')),
    const PopupMenuItem<String>(value: '10', child: Text('10')),
  ];

  // 文明選ぶボタンに表示する文字
  final List<Widget> _civilButtonText = <Widget>[
    const Text('必須', style: TextStyle(fontWeight: FontWeight.bold)),
    const Text('任意', style: TextStyle(fontWeight: FontWeight.bold)),
    const Text('除外', style: TextStyle(fontWeight: FontWeight.bold))
  ];

  @override
  Widget build(BuildContext context) {

    ref.listen(searchParamProvider.select((value) => value.name), (_, next){
      if(_nameController.text != next) _nameController.text = next;
    });
    ref.listen(searchParamProvider.select((value) => value.race), (_, next){
      if(_raceController.text != next) _raceController.text = next;
    });
    ref.listen(searchParamProvider.select((value) => value.type), (_, next){
      if(_typeController.text != next) _typeController.text = next;
    });
    ref.listen(searchParamProvider.select((value) => value.text), (_, next){
      if(_textController.text != next) _textController.text = next;
    });
    ref.listen(searchParamProvider.select((value) => value.costMin), (_, next){
      if(_costMinController.text != next) _costMinController.text = next;
    });
    ref.listen(searchParamProvider.select((value) => value.costMax), (_, next){
      if(_costMaxController.text != next) _costMaxController.text = next;
    });
    ref.listen(searchParamProvider.select((value) => value.powerMin), (_, next){
      if(_powerMinController.text != next) _powerMinController.text = next;
    });
    ref.listen(searchParamProvider.select((value) => value.powerMax), (_, next){
      if(_powerMaxController.text != next) _powerMaxController.text = next;
    });

    // state
    final searchParamState = ref.watch(searchParamProvider);
    // notifier
    final searchParamNotifier = ref.read(searchParamProvider.notifier);

    //画面サイズ
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    return ListView(
        children: [
          Card(
            elevation: 3,
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                spacing: 10,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                          flex: 1,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'カード名',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                            ),
                          )),
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          onChanged: (name) {
                            ref.read(searchParamProvider.notifier).setName(name);
                          },
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            // labelText: "カード名",
                            // suffixIcon: IconButton(onPressed:(){searchParam.resetName();}, icon:const Icon(Icons.clear))
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                          flex: 1,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '種族',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                            ),
                          )),
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          controller: _raceController,
                          textInputAction: TextInputAction.next,
                          onChanged: (race) {
                            ref.read(searchParamProvider.notifier).setRace(race);
                          },
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            // labelText: "種族",
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                          flex: 1,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'タイプ',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                            ),
                          )),
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          controller: _typeController,
                          textInputAction: TextInputAction.next,
                          onChanged: (type) {
                            ref.read(searchParamProvider.notifier).setType(type);
                          },
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            // labelText: "カードタイプ",
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                          flex: 1,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '特殊能力',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                            ),
                          )),
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          controller: _textController,
                          textInputAction: TextInputAction.done,
                          onChanged: (text) {
                            ref.read(searchParamProvider.notifier).setText(text);
                          },
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            // labelText: "特殊能力",
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
              elevation: 3,
              child: Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'コスト',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          controller: _costMinController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onChanged: (cost) {
                            ref.read(searchParamProvider.notifier).setCostMin(cost);
                          },
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(),
                            suffixIcon: PopupMenuButton<String>(
                                elevation: 3,
                                icon: const Icon(Icons.arrow_drop_down_outlined),
                                onSelected: (String value) {
                                  _costMinController.text = value;
                                  ref.read(searchParamProvider.notifier).setCostMin(value);
                                },
                                itemBuilder: (BuildContext context) {
                                  // return _costPopupList;
                                  return [
                                    PopupMenuItem(
                                      padding: EdgeInsets.zero,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: deviceHeight * 0.4,
                                        ),
                                        child: SingleChildScrollView(
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: _costPopupList.map((entry) {
                                                final index = _costPopupList.indexOf(entry);
                                                return Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    entry,
                                                    if (index != _costPopupList.length - 1)
                                                      const Divider(
                                                        height: 1,
                                                        thickness: 1,
                                                        color: Colors.grey,
                                                      ),
                                                  ],
                                                );
                                              }).toList()),
                                        ),
                                      ),
                                    ),
                                  ];
                                }),
                            // suffixIcon: IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_drop_down_outlined)),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '~',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                            textAlign: TextAlign.center,
                            controller: _costMaxController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onChanged: (cost) {
                              ref.read(searchParamProvider.notifier).setCostMax(cost);
                            },
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              suffixIcon: PopupMenuButton<String>(
                                  elevation: 3,
                                  icon: const Icon(Icons.arrow_drop_down_outlined),
                                  onSelected: (String value) {
                                    _costMaxController.text = value;
                                    ref.read(searchParamProvider.notifier).setCostMax(value);
                                  },
                                  itemBuilder: (BuildContext context) {
                                    // return _costPopupList;
                                    return [
                                      PopupMenuItem(
                                        padding: EdgeInsets.zero,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: deviceHeight * 0.4,
                                          ),
                                          child: SingleChildScrollView(
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: _costPopupList.map((entry) {
                                                  final index = _costPopupList.indexOf(entry);
                                                  return Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      entry,
                                                      if (index != _costPopupList.length - 1)
                                                        const Divider(
                                                          height: 1,
                                                          thickness: 1,
                                                          color: Colors.grey,
                                                        ),
                                                    ],
                                                  );
                                                }).toList()),
                                          ),
                                        ),
                                      ),
                                    ];
                                  }),
                              // suffixIcon: IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_drop_down_outlined)),
                            )),
                      ),
                    ],
                  ))),
          Card(
            elevation: 3,
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Row(
                spacing: 10,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'パワー',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: _powerMinController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onChanged: (power) {
                        ref.read(searchParamProvider.notifier).setPowerMin(power);
                      },
                      decoration: const InputDecoration(border: UnderlineInputBorder(), suffixIcon: Icon(Icons.arrow_drop_down_outlined)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '~',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: _powerMaxController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onChanged: (power) {
                        ref.read(searchParamProvider.notifier).setPowerMax(power);
                      },
                      decoration: const InputDecoration(border: UnderlineInputBorder(), suffixIcon: Icon(Icons.arrow_drop_down_outlined)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 3,
            child: Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  spacing: 10,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '文明',
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                        ),
                        TextButton(
                            onPressed: () {
                              ref.read(searchParamProvider.notifier).resetCivilAll();
                            },
                            child: const Text('リセット')),
                      ],
                    ),
                    Visibility(
                        visible: searchParamState.checkCivils,
                        child: Text(
                          '全て不要にすると、1枚も検索できません',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        )),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(spacing: 10, children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '検索単位',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                                ),
                              ),
                              ToggleButtons(
                                  onPressed: (int index) {
                                    ref.read(searchParamProvider.notifier).setCivilSearchUnit(index);
                                  },
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  selectedColor: Theme.of(context).colorScheme.onSecondary,
                                  fillColor: Theme.of(context).colorScheme.secondary,
                                  color: Theme.of(context).colorScheme.primary,
                                  constraints: const BoxConstraints(
                                    minHeight: 40.0,
                                    minWidth: 80.0,
                                  ),
                                  isSelected: searchParamState.civilSearchUnit,
                                  children: const <Widget>[
                                    Text('カード', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('名前', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ])
                            ],
                          ),
                          const Divider(
                            height: 0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '水',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                                ),
                              )),
                              ToggleButtons(
                                // direction: vertical ? Axis.vertical : Axis.horizontal,
                                onPressed: (int index) {
                                  searchParamNotifier.setCivil1(index);
                                },
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                selectedBorderColor: Colors.blue[700],
                                selectedColor: Colors.white,
                                fillColor: Colors.blue[200],
                                color: Colors.blue[400],
                                constraints: const BoxConstraints(
                                  minHeight: 40.0,
                                  minWidth: 80.0,
                                ),
                                isSelected: searchParamState.civil1,
                                children: _civilButtonText,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '光',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                                  ),
                                ),
                              ),
                              ToggleButtons(
                                // direction: vertical ? Axis.vertical : Axis.horizontal,
                                onPressed: (int index) {
                                  searchParamNotifier.setCivil2(index);
                                },
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                selectedBorderColor: Colors.amber[700],
                                selectedColor: Colors.white,
                                fillColor: Colors.amber[200],
                                color: Colors.amber[400],
                                constraints: const BoxConstraints(
                                  minHeight: 40.0,
                                  minWidth: 80.0,
                                ),
                                isSelected: searchParamState.civil2,
                                children: _civilButtonText,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '自然',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                                  ),
                                ),
                              ),
                              ToggleButtons(
                                // direction: vertical ? Axis.vertical : Axis.horizontal,
                                onPressed: (int index) {
                                  searchParamNotifier.setCivil3(index);
                                },
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                selectedBorderColor: Colors.green[700],
                                selectedColor: Colors.white,
                                fillColor: Colors.green[200],
                                color: Colors.green[400],
                                constraints: const BoxConstraints(
                                  minHeight: 40.0,
                                  minWidth: 80.0,
                                ),
                                isSelected: searchParamState.civil3,
                                children: _civilButtonText,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '火',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                                  ),
                                ),
                              ),
                              ToggleButtons(
                                // direction: vertical ? Axis.vertical : Axis.horizontal,
                                onPressed: (int index) {
                                  searchParamNotifier.setCivil4(index);
                                },
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                selectedBorderColor: Colors.red[700],
                                selectedColor: Colors.white,
                                fillColor: Colors.red[200],
                                color: Colors.red[400],
                                constraints: const BoxConstraints(
                                  minHeight: 40.0,
                                  minWidth: 80.0,
                                ),
                                isSelected: searchParamState.civil4,
                                children: _civilButtonText,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '闇',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                                  ),
                                ),
                              ),
                              ToggleButtons(
                                // direction: vertical ? Axis.vertical : Axis.horizontal,
                                onPressed: (int index) {
                                  searchParamNotifier.setCivil5(index);
                                },
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                selectedBorderColor: Colors.deepPurple[700],
                                selectedColor: Colors.white,
                                fillColor: Colors.deepPurple[200],
                                color: Colors.deepPurple[400],
                                constraints: const BoxConstraints(
                                  minHeight: 40.0,
                                  minWidth: 80.0,
                                ),
                                isSelected: searchParamState.civil5,
                                children: _civilButtonText,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'ゼロ',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                                  ),
                                ),
                              ),
                              ToggleButtons(
                                // direction: vertical ? Axis.vertical : Axis.horizontal,
                                onPressed: (int index) {
                                  searchParamNotifier.setCivil6(index);
                                },
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                selectedBorderColor: Colors.blueGrey[700],
                                selectedColor: Colors.white,
                                fillColor: Colors.blueGrey[200],
                                color: Colors.blueGrey[400],
                                constraints: const BoxConstraints(
                                  minHeight: 40.0,
                                  minWidth: 80.0,
                                ),
                                isSelected: searchParamState.civil6,
                                children: _civilButtonText,
                              ),
                            ],
                          ),
                        ]))
                  ],
                )),
          ),
        ],
    );
  }
}
