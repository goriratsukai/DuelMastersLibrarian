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

import '../SubScreen/searchOptionScreen.dart';

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

  @override
  Widget build(BuildContext context) {
    final searchResults = Provider.of<SearchResultsProvider>(context, listen: false);

    //画面サイズ
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Consumer<SearchParamProvider>(
      builder: (context, searchParam, child) => Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // FABを中央下部に配置
        floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(30.0),
                    child: TextFormField(
                      controller: searchParam.nameController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (text) {
                        searchParam.setName(text);
                        // searchResults.search_name(searchParam);
                      },
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                          hintText: 'カード名で検索',
                          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30.0)),
                          prefixIcon: const Icon(Icons.search),
                          // fillColor: Colors.white,
                          // filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          suffixIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchParam.resetName();
                                  }),
                            ],
                          )),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ),
                FloatingActionButton(
                  onPressed: () {
                    // 検索オプション画面を開く
                    _showMultiPageDialog(context);
                    // 画面を開くときに検索フォームのフォーカスを取り除く
                    FocusScope.of(context).unfocus();
                  },
                  // label: const Text('詳細検索'),
                  heroTag: 'optionFAB',
                  child: const Icon(Icons.tune),
                ),
              ],
            )),
        body: FutureBuilder(
            future: searchResults.search_name(searchParam),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              return Consumer<SearchResultsProvider>(builder: (context, searchResults, child) {
                // 検索結果が0件のときはメッセージ表示
                if (searchResults.length == 0) {
                  return const Center(
                    child: Text('検索結果はありません。'),
                  );
                }

                // 検索結果が1件以上あるとき
                // selectの結果を基に検索結果を生成する。見た目の調整の為、最下段にはカードと同じサイズのSizeBoxを配置
                return GridView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: searchResults.length + searchResults.displayColumn,
                  itemBuilder: (context, index) {
                    return searchResults.length > index
                        ? Hero(
                            tag: searchResults.results[index].object_id,
                            child: TestCardContainer(
                              searchedCard: searchResults.results[index],
                              padding: 5,
                            ))
                        : SizedBox(
                            height: deviceWidth / searchResults.displayColumn * 1.4,
                          );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: searchResults.displayColumn, childAspectRatio: 0.715),
                );
              });
            }),
      ),
    );
  }
}

void _showMultiPageDialog(BuildContext context) {
  int _selectedIndex = 0; // 現在選択されているページのインデックス
  // PageControllerを追加するよ！これでPageViewを操作できるんだ！
  final PageController _pageController = PageController();

  showDialog(
    context: context,
    barrierDismissible: true, // バリアをタップしても閉じないようにするよ！
    barrierColor: Colors.black.withAlpha(150),

    builder: (BuildContext dialogContext) {
      // StatefulBuilderを使うと、ダイアログの中で状態を保持できるんだ！
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // ページの内容をリストで用意しておくよ！
              final List<Widget> _pages = <Widget>[
                SearchField(context: context),
                SearchOption(context: context),
              ];
              return Container(
                decoration: BoxDecoration(
                    // color: Theme.of(context).colorScheme.onSecondaryContainer,
                    borderRadius: BorderRadius.circular(15)),
                width: MediaQuery.of(context).size.width * 0.92, // 画面幅の90%
                height: MediaQuery.of(context).size.height * 0.7, // 画面高さの750%
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Column(
                    children: [
                      // ページの内容を表示する部分をExpandedでPageViewに変えるよ！
                      Expanded(
                        child: Container(
                          color: Theme.of(context).colorScheme.surfaceDim,
                          child: PageView(
                            controller: _pageController, // これでPageViewをコントロール！
                            onPageChanged: (int index) {
                              setState(() {
                                _selectedIndex = index; // ページが切り替わったらインデックスを更新！
                                print('index:${index}');
                                print('selectedIndex:${_selectedIndex}');
                              });
                            },
                            children: _pages, // _pagesのリストをPageViewに渡すだけ！
                          ),
                        ),
                      ),
                      // ボトムバー（BottomNavigationBar）だよ！
                      ClipRRect(
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                        child: BottomNavigationBar(
                          elevation: 3,
                          // backgroundColor: Colors.white.withAlpha(0),
                          items: const <BottomNavigationBarItem>[
                            BottomNavigationBarItem(
                              icon: Icon(Icons.filter_alt_outlined),
                              label: 'フィルタ',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.settings),
                              label: 'オプション',
                            ),
                          ],
                          currentIndex: _selectedIndex,
                          // 現在選択されているインデックス
                          selectedItemColor: Colors.amber[800],
                          // 選択されたアイコンの色
                          unselectedItemColor: Colors.black54,
                          onTap: (int index) {
                            setState(() {
                              _selectedIndex = index; // タップされたらインデックスを更新！
                              // ここでPageViewを切り替えるようにするよ！
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 200), // ちょっとアニメーションつけてみた！
                                curve: Curves.ease, // 動きもなめらかに！
                              );
                            });
                          },
                        ),
                      ),
                      // 閉じるボタンとかが必要ならここに追加！
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 10,
                        children: [
                          // Consumer<SearchParamProvider>(
                          //   builder: (context, searchParam, child) => ElevatedButton.icon(
                          //     onPressed: () {
                          //       searchParam.resetAll();
                          //     },
                          //     label: const Text('リセット'),
                          //     icon: const Icon(Icons.refresh_outlined),
                          //   ),
                          // ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(); // ダイアログを閉じる
                            },
                            label: const Text('閉じる'),
                            icon: const Icon(Icons.clear_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
