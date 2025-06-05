import 'dart:io';

import 'package:animations/animations.dart';
import 'package:dml/provider/search_param_provider.dart';
import 'package:dml/provider/search_result_provider.dart';
import 'package:dml/widgets/searched_card_container.dart';
import 'package:flutter/material.dart';
import 'package:dml/source/card_data.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dml/theme.dart';

import 'package:dml/SubScreen/searchCardScreen.dart';

double deviceHeight = 0.0;
double deviceWidth = 0.0;

final ScrollController _scrollController = ScrollController();
double _firstVisibleRowIndex = 0;

enum Menu { Item1, Item2, Item3 }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  // 1ぺーじに表示するカードの枚数
  int _page_coun = 60;

  final ScrollController _scrollController2 = ScrollController();

  void scrollToTop() {
    _scrollController2.animateTo(0,
        duration: const Duration(milliseconds: 100), curve: Curves.linear);
  }

  final List<Widget> viewColumnCount = [
    const Icon(Icons.looks_two_outlined),
    const Icon(Icons.looks_3_outlined),
    const Icon(Icons.looks_4_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final searchResults =
    Provider.of<SearchResultsProvider>(context, listen: false);

    //画面サイズ
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Consumer<SearchParamProvider>(
      builder: (context, searchParam, child) => Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  // ここをカスタムダイアログに変更
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // Consumerで囲んでsearchResultsの変更を検知できるようにする
                      return Consumer<SearchResultsProvider>(
                        builder: (context, searchResultsDialog, child) {
                          double currentColumn = searchResultsDialog.displayColumn.toDouble();
                          return AlertDialog( // SimpleDialogからAlertDialogに変更
                            title: const Text("表示する列数を選択"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Slider(
                                  value: currentColumn,
                                  min: 2,
                                  max: 4,
                                  divisions: 2, // 2, 3, 4の3つの選択肢
                                  label: currentColumn.round().toString(),
                                  onChanged: (double value) {
                                    // スライダーの値を変更したらすぐに反映
                                    // setStateでConsumerを再ビルドさせる
                                    searchResultsDialog.setDisplayColumn(value.round());
                                  },
                                ),
                                Text('現在の列数: ${searchResultsDialog.displayColumn}列'),
                                Consumer<SearchParamProvider>(
                                    builder: (context, searchParam, child) =>
                                        SwitchListTile(
                                            title: const Text('同名カードを表示する'),
                                            value: searchParam.sameName ,
                                            onChanged:(value){searchParam.setSameName(value);
                                            }
                                        )
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              ElevatedButton(onPressed: (){Navigator.pop(context);}, child: const Text('閉じる'))
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                icon: Consumer<SearchResultsProvider>(
                  builder: (context, searchResults2, child) =>
                  viewColumnCount[searchResults2.displayColumn - 2],
                )),
          ],
          title: TextFormField(
            controller: searchParam.nameController,
            textCapitalization: TextCapitalization.words,
            onChanged: (text) {
              searchParam.setName(text);
              searchResults.search_name(searchParam);
            },
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              // fillColor: Theme.of(context).colorScheme.surface,
              hintText: "カード名で検索",
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(32),
              ),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchParam.resetName();
                  }),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return SearchField(
                context: context,
                searchFunc: searchResults.search_name,
              );
            }));
          },
          label: const Text('詳細検索'),
          icon: const Icon(Icons.tune_rounded),
        ),
        body: FutureBuilder(
            future: searchResults.search_name(searchParam),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              return Consumer<SearchResultsProvider>(
                  builder: (context, searchResults, child) {
                    // selectの結果を基に検索結果を生成する。見た目の調整の為、最下段にはカードと同じサイズのSizeBoxを配置
                    return GridView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: searchResults.length + searchResults.displayColumn,
                      // itemCount: _page_coun + searchResults.displayColumn,
                      itemBuilder: (context, index) {
                        return searchResults.length > index
                            ? Hero(
                            tag: searchResults.results[index].object_id,
                            child: TestCardContainer(
                              searchedCard: searchResults.results[index],
                              padding: 5,
                            ))
                            : SizedBox(
                          height:
                          deviceWidth / searchResults.displayColumn * 1.4,
                        );
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: searchResults.displayColumn,
                          childAspectRatio: 0.715),
                    );
                  });
            }),
      ),
    );
  }

  void beforeItemCountChange(double itemHeight, int crossAxisCount) {
    final offset = _scrollController.offset;
    _firstVisibleRowIndex = offset / itemHeight * crossAxisCount;
    print(_firstVisibleRowIndex);
  }

  void afterItemCountChange(double itemHeight, int crossAxisCount) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newOffset = _firstVisibleRowIndex * itemHeight / crossAxisCount;
      final maxScrollOffset = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(newOffset.clamp(0.0, maxScrollOffset));
    });
  }
}