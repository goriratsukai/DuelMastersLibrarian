import 'package:dml/SubScreen/searchCardScreen.dart';
import 'package:dml/SubScreen/searchOptionScreen.dart';
import 'package:flutter/material.dart';

void showMultiPageDialog(BuildContext context) {
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
