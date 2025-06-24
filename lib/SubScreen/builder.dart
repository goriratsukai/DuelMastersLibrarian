import 'package:dml/provider/build_deck_provider.dart';
import 'package:dml/provider/search_param_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'show_multipage_dialog.dart';
import '../provider/search_result_provider.dart';
import '../source/card_data.dart';
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
  // カード名検索のコントローラ
  late final TextEditingController _nameController;

  // 並び替えモードの状態を管理するフラグ
  bool _isReorderMode = false;

  @override
  void initState() {
    // カード名検索の初期値セット
    final initialParams = ref.read(searchParamProvider);
    _nameController = TextEditingController(text: initialParams.name);
    super.initState();
  }

  @override
  void dispose(){
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final asyncSearchResults = ref.watch(searchResultsProvider);
    // final buildDeck = ref.watch(buildDeckProvider);

    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    double deckAreaHeight = deviceWidth * 7 / 8;
    int crossAxisCount = 8;
    double childAspectRatio = 0.715;
    final itemWidth = deviceWidth / crossAxisCount;
    final itemHeight = itemWidth / childAspectRatio;

    return Scaffold(
      appBar: AppBar(
        title: const Text('デッキ作る画面'),
        leading: IconButton(onPressed: () => {Navigator.pop(context)}, icon: const Icon(Icons.arrow_back)),
        actions: [
          // テスト用入れ替えボタン
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'テスト入替',
            onPressed: () {
              // デッキにカードが2枚以上あるか確認
              if (ref.read(buildDeckProvider).mainDeck.length >= 2) {
                print('テストボタンが押されました: 0番目と1番目を入れ替えます');
                // Providerを直接呼び出して、0番目と1番目のカードを入れ替える
                ref.read(buildDeckProvider.notifier).swapCards(DeckType.main,0, 1);
              } else {
                print('入れ替えにはカードが2枚以上必要です');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('入れ替えにはカードが2枚以上必要です')),
                );
              }
            },
          ),

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
                              ref.read(buildDeckProvider.notifier).resetMainDeck();
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
                    controller:_nameController,
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
                  child: Consumer(builder: (context, ref, child) {
                    final buildDeck = ref.watch(buildDeckProvider);
                    return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: buildDeck.mainDeck.length,
                        itemBuilder: (context, index) {
                          final card = buildDeck.mainDeck[index];

                          // debug print
                          print('index: $index, card_name: ${card.card_name}, hashCode: ${card.hashCode}');

                          // カードの基本UI
                          final cardWidget = DeletableCardContainer(
                              searchedCard: card,
                              index: index,
                              // 並び替えモードの状態を渡す
                              isReorderMode: _isReorderMode);
                          // 通常モードのときはカードの基本UIを使う
                          Widget item = cardWidget;

                          // 並び替えモードの時はDraggableとDragTargetでラップしたものに置き換える
                          if (_isReorderMode) {
                            item = Draggable<int>(
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
                                onWillAcceptWithDetails: (fromIndex) {
                                  // 自分自身の上にはドロップできないようにする
                                  return fromIndex.data != index;
                                },
                                onAcceptWithDetails: (fromIndex) {
                                  // カードを入れ替える
                                  ref.read(buildDeckProvider.notifier).swapCards(DeckType.main,fromIndex.data, index);
                                },
                              ),
                            );
                          }

                          // keyを付与してreturn
                          return KeyedSubtree(key: ValueKey(card), child: item);
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                        ));
                  }));
            },
            onWillAcceptWithDetails: (details) {
              return true;
            },
            onAcceptWithDetails: (card) {
              final result = ref.read(buildDeckProvider.notifier).addMainDeck(card.data);
              if (result == 1) {
                Fluttertoast.showToast(msg: '同名カードは4枚まで追加できます。${card.data.card_name}');
              } else if (result == 2) {
                Fluttertoast.showToast(msg: 'メインデッキの上限に達しました。カードは60枚まで追加できます');
              }
            },
          ),
          BottomNavigationBar(items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.qr_code),label: 'メインデッキ'
            ),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code),label: '超次元/GR'
            ),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code),label: ''
            ),
          ],),

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
