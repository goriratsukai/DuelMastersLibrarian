import 'dart:io';

import 'package:animations/animations.dart';
import 'package:dml/provider/search_param_provider.dart';
import 'package:dml/provider/search_result_provider.dart';
import 'package:dml/widgets/searched_card_container.dart';
import 'package:flutter/material.dart';
import 'package:dml/source/card_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dml/theme.dart';

import 'package:dml/SubScreen/searchCardScreen.dart';

import '../SubScreen/searchOptionScreen.dart';

double deviceHeight = 0.0;
double deviceWidth = 0.0;

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends ConsumerState<SearchScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider.notifier);

    final asyncSearchResults = ref.watch(searchResultsProvider);

    ref.listen(searchParamProvider.select((value) => value.name), (_, next) {
      if (_textController.text != next) {
        _textController.text = next;
      }
    });

    //画面サイズ
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
                      controller: _textController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (text) {
                        ref.read(searchParamProvider.notifier).setName(text);
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
                                    ref.read(searchParamProvider.notifier).resetName();
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
        body: asyncSearchResults.when(
          data: (results) {
            if (results.isEmpty) {
              return const Center(
                child: Text('検索結果はありません。'),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              itemCount: results.length + ref.watch(displayColumnProvider),
              itemBuilder: (context, index) {
                return results.length > index
                    ? TestCardContainer(searchedCard: results[index], padding: 5)

                    : SizedBox(
                        height: deviceWidth / ref.watch(displayColumnProvider) * 1.4,
                      );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: ref.watch(displayColumnProvider), childAspectRatio: 0.715),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
        ));
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
              final List<Widget> pages = <Widget>[
                SearchField(),
                SearchOption(),
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
                            children: pages, // _pagesのリストをPageViewに渡すだけ！
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
