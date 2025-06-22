import 'package:animations/animations.dart';
import 'package:dml/provider/build_deck_provider.dart';
import 'package:dml/provider/search_param_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:fluttertoast/fluttertoast.dart';


import 'searchCardScreen.dart';
import 'show_multipage_dialog.dart';
import '../provider/search_result_provider.dart';
import '../source/card_data.dart';
import '../source/grid_painter.dart';
import '../widgets/deck_Information.dart';
import '../widgets/searched_card_container.dart';

double deviceHeight = 0.0;
double deviceWidth = 0.0;

// ConsumerWidget から ConsumerStatefulWidget に変更
class BuildDeckScreen extends ConsumerStatefulWidget {
  BuildDeckScreen({super.key});

  @override
  ConsumerState<BuildDeckScreen> createState() => _BuildDeckScreenState();
}

class _BuildDeckScreenState extends ConsumerState<BuildDeckScreen> {
  final _textController = TextEditingController();

  // 並び替えモードの状態を管理するフラグ
  bool _isReorderMode = false;

  @override
  Widget build(BuildContext context) {
    // ref は ConsumerState のプロパティとしてアクセスできるよ
    ref.listen(searchParamProvider.select((value) => value.name), (_, next) {
      if (_textController.text != next) {
        _textController.text = next;
      }
    });

    final asyncSearchResults = ref.watch(searchResultsProvider);
    final buildDeck = ref.watch(buildDeckProvider);

    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    double deckAreaHeight;
    int crossAxisCount = 8;
    double childAspectRatio = 0.715;
    final itemWidth = deviceWidth / crossAxisCount;
    final itemHeight = itemWidth / childAspectRatio;

    if (buildDeck.length <= 40) {
      deckAreaHeight = deviceWidth * 7 / 8;
    } else {
      final rowCount = (buildDeck.length / crossAxisCount).ceil();
      deckAreaHeight = itemHeight * rowCount;
    }

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('戻る', style: TextStyle(fontSize: 10)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(buildDeckProvider.notifier).resetDeck();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('デッキをクリアしました')),
                  );
                },
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('クリア', style: TextStyle(fontSize: 10)),
              ),
              // このボタンはAppBarに移動したので、コメントアウトか削除
              // ElevatedButton.icon(
              //   onPressed: () {
              //     setState(() {
              //       _isReorderMode = !_isReorderMode;
              //     });
              //   },
              //   icon: const Icon(Icons.sort_rounded),
              //   label: const Text('並べ替え', style: TextStyle(fontSize: 10)),
              // ),
              ElevatedButton.icon(
                onPressed: () {
                  print('保存ボタンが押されたよ！');
                },
                icon: const Icon(Icons.save_rounded),
                label: const Text('保存', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('デッキ作る画面'),
        leading: IconButton(onPressed: () => {Navigator.pop(context)}, icon: const Icon(Icons.arrow_back)),
        actions: [
          // ここに並び替えモード切替ボタンを追加！
          IconButton(
            tooltip: '並び替えモード切替',
            icon: _isReorderMode ? const Icon(Icons.check) : const Icon(Icons.sort),
            onPressed: () {
              setState(() {
                _isReorderMode = !_isReorderMode;
              });
            },
          ),
          // リセットボタン
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext buildContext) {
                      return AlertDialog(
                        title: Text('全削除'),
                        content: Text('デッキに入れたカードを全て削除しますか？'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(buildContext).pop(); // ダイアログを閉じる
                            },
                            child: Text('キャンセル'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(buildDeckProvider.notifier).resetDeck();
                              Navigator.of(buildContext).pop(); // ダイアログを閉じる
                            },
                            child: Text('削除'),
                          ),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.delete_rounded)),
          IconButton(onPressed: () => {}, icon: const Icon(Icons.save_rounded)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                    enabled: !_isReorderMode,
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
                onPressed: _isReorderMode
                    ? null
                    : () {
                        showMultiPageDialog(context);
                        FocusScope.of(context).unfocus();
                      },
                heroTag: 'optionFAB',
                child: const Icon(Icons.tune),
              ),
            ],
          )),
      body: SafeArea(
          child: Stack(children: [
        Column(spacing: 10, children: [
          // デッキエリア
          DragTarget<SearchCard>(
            builder: (context, candidateData, rejectedData) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                width: double.infinity,
                height: deckAreaHeight,
                child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: buildDeck.length,
                    itemBuilder: (context, index) {
                      final card = buildDeck[index];

                      // カードの基本UI
                      Widget cardWidget =
                      DeletableCardContainer(
                        // アニメーションのためにユニークなキーを設定
                        key: ValueKey('${card.image_name}_${index}'),
                        searchedCard: card,
                        index: index,
                        // 並び替えモードの状態を渡す
                        isReorderMode: _isReorderMode,
                      );

                      // 並び替えモードの時だけDraggableとDragTargetでラップする
                      if (_isReorderMode) {
                        return Draggable<int>(
                          data: index,
                          // ドラッグ中の見た目
                          feedback: SizedBox(
                            width: itemWidth,
                            height: itemHeight,
                            child: TestCardContainer(searchedCard: card, padding: 0),
                          ),
                          // ドラッグ中に元の場所に表示されるウィジェット
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: cardWidget,
                          ),
                          child: DragTarget<int>(
                            builder: (context, candidateData, rejectedData) {
                              return cardWidget;
                            },
                            onWillAccept: (fromIndex) {
                              // 自分自身の上にはドロップできないようにする
                              return fromIndex != index;
                            },
                            onAccept: (fromIndex) {
                              // カードを入れ替える
                              ref.read(buildDeckProvider.notifier).swapCards(fromIndex, index);
                            },
                          ),
                        );
                      }

                      // 通常モードのときはそのまま表示
                      return cardWidget;
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                    )),
              );
            },
            onWillAcceptWithDetails: (details) {
              return true;
            },
            onAcceptWithDetails: (card) {
              final result = ref.read(buildDeckProvider.notifier).addDeck(card.data);
              if (result == 1) {
                Fluttertoast.showToast(msg:'同名カードは4枚まで追加できます。${card.data.card_name}');
              } else if (result == 2) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('メインデッキの上限に達しました。カードは60枚まで追加できます'),
                ));
              }
            },
          ),
          // 検索結果エリア
          Container(
            color: Theme.of(context).colorScheme.secondaryContainer,
            width: double.infinity,
            height: deviceWidth * 2.8 / 10,
            child: asyncSearchResults.when(
              data: (results) {
                if (results.isEmpty) {
                  return const Center(
                    child: Text('検索結果はありません。'),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return DraggableCardContainer(
                      searchedCard: results[index],
                      height: deviceWidth * 1.4 / 5,
                      width: deviceWidth / 5,
                      padding: 1,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text(error.toString())),
            ),
          )
        ]),
        if (_isReorderMode)
          Column(
            children: [
              // デッキエリアの高さ分の透明なスペースを置いて、デッキエリアは触れるようにする
              SizedBox(height: deckAreaHeight),
              // デッキエリア以外を覆う半透明のコンテナ
              Expanded(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'デッキのカードをドラッグ＆ドロップして\n好きな順番に並び替えよう！',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 8.0,
                            color: Colors.black.withAlpha(150),
                            offset: const Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ])),
    );
  }
}
