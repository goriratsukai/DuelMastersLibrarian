import 'package:animations/animations.dart';
import 'package:dml/provider/build_deck_provider.dart';
import 'package:dml/provider/search_param_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'searchCardScreen.dart';
import 'show_multipage_dialog.dart';
import '../provider/search_result_provider.dart';
import '../source/card_data.dart';
import '../source/grid_painter.dart';
import '../widgets/deck_Information.dart';
import '../widgets/searched_card_container.dart';

double deviceHeight = 0.0;
double deviceWidth = 0.0;

class BuildDeckScreen extends ConsumerWidget {
  BuildDeckScreen({super.key});

  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // カード検索フォームのコントローラー
    ref.listen(searchParamProvider.select((value) => value.name), (_, next) {
      if (_textController.text != next) {
        _textController.text = next;
      }
    });

    // 検索結果を監視する
    final asyncSearchResults = ref.watch(searchResultsProvider);

    // 構築中デッキデータのprovider
    final buildDeck = ref.watch(buildDeckProvider);

    //画面サイズ
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    // デッキ枚数に応じた高さと表示列数を計算する
    double deckAreaHeight;
    int crossAxisCount = 8;
    double childAspectRatio = 0.715;

    if (buildDeck.length <= 40) {
      // デッキが40枚以下の間は高さ固定
      deckAreaHeight = deviceWidth * 7 / 8;
    }else{
      final itemWidth = deviceWidth / crossAxisCount;
      final itemHeight = itemWidth / childAspectRatio;
      // 行数を計算
      final rowCount = (buildDeck.length / crossAxisCount).ceil();
      // GridViewの高さを計算
      deckAreaHeight = itemHeight * rowCount;
    }


    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // ボタンをいい感じに配置
            children: [
              // 戻るボタン
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('戻る', style: TextStyle(fontSize: 10)),
                style: ElevatedButton.styleFrom(
                    // backgroundColor: Colors.grey[700], // 色をちょっと調整
                    // foregroundColor: Colors.white,
                    ),
              ),
              // クリアボタン
              ElevatedButton.icon(
                onPressed: () {
                  // デッキをリセットする処理
                  ref.read(buildDeckProvider.notifier).resetDeck();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('デッキをクリアしました')),
                  );
                },
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('クリア', style: TextStyle(fontSize: 10)),
                style: ElevatedButton.styleFrom(
                    // backgroundColor: Colors.grey[700], // 色をちょっと調整
                    // foregroundColor: Colors.white,
                    ),
              ),
              // 並べ替えモードボタン
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.sort_rounded),
                label: const Text('並べ替え', style: TextStyle(fontSize: 10)),
              ),

              // 保存ボタン
              ElevatedButton.icon(
                onPressed: () {
                  // ここに保存処理を書く（今はまだ空でOK！）
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
          IconButton(
              onPressed: () {
                ref.read(buildDeckProvider.notifier).resetDeck();
              },
              icon: const Icon(Icons.clear_all_rounded)),
          IconButton(onPressed: () => {}, icon: const Icon(Icons.save_rounded)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // FABを中央下部に配置
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
                  showMultiPageDialog(context);
                  // 画面を開くときに検索フォームのフォーカスを取り除く
                  FocusScope.of(context).unfocus();
                },
                // label: const Text('詳細検索'),
                heroTag: 'optionFAB',
                child: const Icon(Icons.tune),
              ),
            ],
          )),

      body: SafeArea(
        child: Column(spacing: 10, children: [
          // デッキエリア
          DragTarget<SearchCard>(
            builder: (context, candidateData, rejectedData) {
              return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  width: double.infinity,
                  height: deckAreaHeight,
                  child:
                    GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: buildDeck.length,
                        itemBuilder: (context, index) {
                          return DeletableCardContainer(
                            searchedCard: buildDeck[index],
                            index: index,
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                        )
                        // const Align(
                        //   alignment: Alignment.center,
                        //   child: Text('デッキのカードが表示される所'),
                        // ),
                        ),
                  );
            },
            onWillAcceptWithDetails: (details) {
              return true;
            },
            onAcceptWithDetails: (card) {
              final result = ref.read(buildDeckProvider.notifier).addDeck(card.data);
              if (result == 0) {
                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                //   content: Text('成功：${card.data.card_name}'),
                // ));
              } else if (result == 1){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('同名カードは4枚まで追加できます。${card.data.card_name}'),
                ));
              } else {
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
        // floatingActionButton:FloatingActionButton(onPressed: null,child: Icon(Icons.save),)
      ),
    );
  }
}
