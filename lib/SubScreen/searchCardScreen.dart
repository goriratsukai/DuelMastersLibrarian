import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:dml/provider/search_param_provider.dart';
import 'package:provider/provider.dart';

class SearchField extends StatelessWidget {
  SearchField({
    super.key,
    required this.context,
  });

  final BuildContext context;

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
    //画面サイズ
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    return Consumer<SearchParamProvider>(
      builder: (context, searchParam, child) => ListView(
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
                          controller: searchParam.nameController,
                          textInputAction: TextInputAction.next,
                          onChanged: (name) {
                            searchParam.setName(name);
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
                          controller: searchParam.raceController,
                          textInputAction: TextInputAction.next,
                          onChanged: (race) {
                            searchParam.setRace(race);
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
                          controller: searchParam.typeController,
                          textInputAction: TextInputAction.next,
                          onChanged: (type) {
                            searchParam.setType(type);
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
                          controller: searchParam.textController,
                          textInputAction: TextInputAction.done,
                          onChanged: (text) {
                            searchParam.setText(text);
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
                          controller: searchParam.costMinController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onChanged: (cost) {
                            searchParam.setCostMin(cost);
                          },
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(),
                            suffixIcon: PopupMenuButton<String>(
                                elevation: 3,
                                icon: const Icon(Icons.arrow_drop_down_outlined),
                                onSelected: (String value) {
                                  searchParam.costMinController.text = value;
                                  searchParam.setCostMin(value);
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
                            controller: searchParam.costMaxController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onChanged: (cost) {
                              searchParam.setCostMax(cost);
                            },
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              suffixIcon: PopupMenuButton<String>(
                                  elevation: 3,
                                  icon: const Icon(Icons.arrow_drop_down_outlined),
                                  onSelected: (String value) {
                                    searchParam.costMaxController.text = value;
                                    searchParam.setCostMax(value);
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
                      controller: searchParam.powerMinController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onChanged: (power) {
                        searchParam.setPowerMin(power);
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
                      controller: searchParam.powerMaxController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onChanged: (power) {
                        searchParam.setPowerMax(power);
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
                              searchParam.resetCivilAll();
                            },
                            child: const Text('リセット')),
                      ],
                    ),
                    Visibility(
                        visible: searchParam.checkCivils,
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
                                    searchParam.setCivilSearchUnit(index);
                                  },
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  selectedColor: Theme.of(context).colorScheme.onSecondary,
                                  fillColor: Theme.of(context).colorScheme.secondary,
                                  color: Theme.of(context).colorScheme.primary,
                                  constraints: const BoxConstraints(
                                    minHeight: 40.0,
                                    minWidth: 80.0,
                                  ),
                                  isSelected: searchParam.civilSearchUnit,
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
                                  searchParam.setCivil1(index);
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
                                isSelected: searchParam.civil1,
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
                                  searchParam.setCivil2(index);
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
                                isSelected: searchParam.civil2,
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
                                  searchParam.setCivil3(index);
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
                                isSelected: searchParam.civil3,
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
                                  searchParam.setCivil4(index);
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
                                isSelected: searchParam.civil4,
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
                                  searchParam.setCivil5(index);
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
                                isSelected: searchParam.civil5,
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
                                  searchParam.setCivil6(index);
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
                                isSelected: searchParam.civil6,
                                children: _civilButtonText,
                              ),
                            ],
                          ),
                        ]))
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
