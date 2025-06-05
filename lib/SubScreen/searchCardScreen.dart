import 'package:flutter/material.dart';
import 'package:dml/provider/search_param_provider.dart';
import 'package:provider/provider.dart';

class SearchField extends StatelessWidget {
  SearchField({
    super.key,
    required this.context,
    required this.searchFunc,
  });

  final BuildContext context;
  final Function(SearchParamProvider) searchFunc;

  // 文明選ぶボタンに表示する文字
  final List<Widget> _civilButtonText = <Widget>[
    const Text('必須', style: TextStyle(fontWeight: FontWeight.bold)),
    const Text('任意', style: TextStyle(fontWeight: FontWeight.bold)),
    const Text('不要', style: TextStyle(fontWeight: FontWeight.bold))
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchParamProvider>(
      builder: (context, searchParam, child) => Scaffold(
        appBar: AppBar(
          // title: const Text('詳しい条件で検索'),
          elevation: 4,
          actions: [
            TextButton.icon(
                onPressed: searchParam.resetAll,
                label: const Flexible(child: Text('リセット')),
                icon: const Icon(Icons.restart_alt_rounded)),
            TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  searchFunc(searchParam);
                },
                label: const Flexible(child: Text('検索')),
                icon: const Icon(Icons.search_rounded)),
          ],
        ),
        body: ListView(
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
                          const Expanded(
                            flex: 1,
                            child:
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'カード名',
                                textAlign: TextAlign.center,
                              ),
                            )
                          ),
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
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                          spacing: 10,
                          children: [
                        const Expanded(
                          flex: 1,
                          child:
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '種族',
                              textAlign: TextAlign.center,
                            ),
                          )
                        ),
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
                      ]),
                      Row(
                          spacing: 10,
                          children: [
                        const Expanded(
                          flex: 1,
                          child:
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'タイプ',
                              textAlign: TextAlign.center,
                            ),
                          )
                        ),
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
                      ]),
                      Row(
                          spacing: 10,
                          children: [
                        const Expanded(
                          flex: 1,
                          child:
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '特殊能力',
                              textAlign: TextAlign.center,
                            ),
                          )
                        ),
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
                      ]),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                    ],
                  ),
                  ),

            ),
            // Card(
            //   elevation: 3,
            //   child: Container(
            //       margin: const EdgeInsets.all(10),
            //       child: Column(children: [
            //         const Row(
            //           children: [
            //             Expanded(
            //                 flex: 1,
            //                 child: Text(
            //                   '特殊能力②',
            //                   textAlign: TextAlign.left,
            //                 ))
            //           ],
            //         ),
            //         Row(children: [Expanded(flex: 1, child: Container()),
            //           Expanded(
            //             flex: 5,
            //             child: TextFormField(
            //               // controller: searchParam.textController,
            //               // textInputAction: TextInputAction.done,
            //               onChanged: (text) {
            //                 // searchParam.setText(text);
            //               },
            //               decoration: InputDecoration(
            //                 border: const UnderlineInputBorder(),
            //                 suffixIcon: IconButton(
            //                     onPressed: () {},
            //                     icon:
            //                         const Icon(Icons.arrow_drop_down_outlined)),
            //               ),
            //             ),
            //           ),
            //         ]),
            //         Row(children: [
            //           Expanded(flex: 1, child: Container()),
            //           Expanded(
            //             flex: 5,
            //             child: TextFormField(
            //               // controller: searchParam.textController,
            //               // textInputAction: TextInputAction.done,
            //               onChanged: (text) {
            //                 // searchParam.setText(text);
            //               },
            //               decoration: InputDecoration(
            //                 border: const UnderlineInputBorder(),
            //                 suffixIcon: IconButton(
            //                     onPressed: () {},
            //                     icon:
            //                         const Icon(Icons.arrow_drop_down_outlined)),
            //               ),
            //             ),
            //           )
            //         ])
            //       ])),
            // ),
            Card(
                elevation: 3,
                child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Row(
                      spacing: 10,
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'コスト',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: searchParam.costMinController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onChanged: (cost) {
                              searchParam.setCostMin(cost);
                            },
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              suffixIcon: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                      Icons.arrow_drop_down_outlined)),
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Text(
                            '~',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                              controller: searchParam.costMaxController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              onChanged: (cost) {
                                searchParam.setCostMax(cost);
                              },
                              decoration: InputDecoration(
                                border: const UnderlineInputBorder(),
                                suffixIcon: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                        Icons.arrow_drop_down_outlined)),
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
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'パワー',
                          textAlign: TextAlign.center,
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
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              suffixIcon: Icon(Icons.arrow_drop_down_outlined)),
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Text(
                          '~',
                          textAlign: TextAlign.center,
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
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              suffixIcon: Icon(Icons.arrow_drop_down_outlined)),
                        ),
                      ),
                    ],
                  ),
                )),
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
                          const Text('文明'),
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
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          )),
                      Row(
                        children: [
                          const Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text('検索単位'),
                              )),
                          Expanded(
                              flex: 5,
                              child: ToggleButtons(
                                  onPressed: (int index) {
                                    searchParam.setCivilSearchUnit(index);
                                  },
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  selectedColor:
                                      Theme.of(context).colorScheme.onSecondary,
                                  fillColor:
                                      Theme.of(context).colorScheme.secondary,
                                  color: Theme.of(context).colorScheme.primary,
                                  constraints: const BoxConstraints(
                                    minHeight: 40.0,
                                    minWidth: 120.0,
                                  ),
                                  isSelected: searchParam.civilSearchUnit,
                                  children: const <Widget>[
                                    Text('カード',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text('名前',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ]))
                        ],
                      ),
                      const Divider(
                        height: 0,
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('水'),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: ToggleButtons(
                              // direction: vertical ? Axis.vertical : Axis.horizontal,
                              onPressed: (int index) {
                                searchParam.setCivil1(index);
                              },
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
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
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('光'),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: ToggleButtons(
                              // direction: vertical ? Axis.vertical : Axis.horizontal,
                              onPressed: (int index) {
                                searchParam.setCivil2(index);
                              },
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
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
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('自然'),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: ToggleButtons(
                              // direction: vertical ? Axis.vertical : Axis.horizontal,
                              onPressed: (int index) {
                                searchParam.setCivil3(index);
                              },
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
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
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('火'),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: ToggleButtons(
                              // direction: vertical ? Axis.vertical : Axis.horizontal,
                              onPressed: (int index) {
                                searchParam.setCivil4(index);
                              },
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
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
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('闇'),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: ToggleButtons(
                              // direction: vertical ? Axis.vertical : Axis.horizontal,
                              onPressed: (int index) {
                                searchParam.setCivil5(index);
                              },
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
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
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('ゼロ'),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: ToggleButtons(
                              // direction: vertical ? Axis.vertical : Axis.horizontal,
                              onPressed: (int index) {
                                searchParam.setCivil6(index);
                              },
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
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
                          )
                        ],
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
