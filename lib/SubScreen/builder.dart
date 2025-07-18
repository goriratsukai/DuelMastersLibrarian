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

// ConsumerStatefulWidget に変更
class BuildDeckScreen extends ConsumerStatefulWidget {
  BuildDeckScreen({super.key,required this.buildMode});

  final String buildMode;

  @override
  ConsumerState<BuildDeckScreen> createState() => _BuildDeckScreenState();
}

// TickerProviderStateMixin を追加
class _BuildDeckScreenState extends ConsumerState<BuildDeckScreen> with TickerProviderStateMixin {
  // カード名検索のコントローラ
  late final TextEditingController _nameController;

  // 並び替えモードの状態を管理するフラグ
  bool _isReorderMode = false;

  // TabController を追加
  late TabController _tabController;

  @override
  void initState() {
    // カード名検索の初期値セット
    final initialParams = ref.read(searchParamProvider);
    _nameController = TextEditingController(text: initialParams.name);
    // TabControllerを初期化
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tabController.dispose(); // TabControllerを破棄
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// 名前検索欄（状態）が更新されたら画面にも反映する
    ref.listen(searchParamProvider.select((value) => value.name), (_, next) {
      if (_nameController.text != next) _nameController.text = next;
    });

    final asyncSearchResults = ref.watch(searchResultsProvider);

    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    double deckAreaHeight = deviceWidth * 7 / 8;
    int crossAxisCount = 8;
    final itemWidth = deviceWidth / crossAxisCount;

    return Scaffold(
      appBar: AppBar(
        title: widget.buildMode == 'EDIT'? const Text('デッキ編集') : const Text('新規デッキ作成'),
        leading: IconButton(onPressed: () => {Navigator.pop(context)}, icon: const Icon(Icons.arrow_back)),
        actions: [
          IconButton(
            tooltip: '並び替えモード切替',
            icon: _isReorderMode ? const Icon(Icons.check) : const Icon(Icons.sort),
            onPressed: () {
              setState(() {
                _isReorderMode = !_isReorderMode;
              });
            },
          ),
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
                              Navigator.of(buildContext).pop();
                            },
                            child: Text('キャンセル'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(buildDeckProvider.notifier).resetMainDeck();
                              Navigator.of(buildContext).pop();
                            },
                            child: Text('削除'),
                          ),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.delete_rounded)),
          IconButton(
              onPressed: () => {_showSaveDialog(context, ref, buildMode: widget.buildMode)},
              icon: const Icon(Icons.save_rounded)),
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
                    controller: _nameController,
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
              Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'メインデッキ'),
                      Tab(text: '外部デッキ'),
                    ],
                  ),
                  SizedBox(
                      height: deckAreaHeight,
                      child: DragTarget<SearchCard>(
                        builder: (context, candidateData, rejectedData) {
                          return TabBarView(
                            physics: const NeverScrollableScrollPhysics(), // スワイプ無効
                            controller: _tabController,
                            children: [
                              // メインデッキ表示
                              _buildMainDeckArea(deckAreaHeight, crossAxisCount, itemWidth),
                              // 外部デッキ表示
                              _buildExternalDeckArea(deckAreaHeight, crossAxisCount, itemWidth),
                            ],
                          );
                        },
                        onWillAcceptWithDetails: (details) {
                          // ここを修正！
                          final card = details.data;
                          if (card.belong_deck == 0) {
                            _tabController.animateTo(0);
                          } else {
                            _tabController.animateTo(1);
                          }
                          return true;
                        },
                        onAcceptWithDetails: (card) {
                          final result = ref.read(buildDeckProvider.notifier).addDeck(card.data);
                          print(card.data.card_name);
                          print(card.data.image_name);
                          print(card.data.object_id);
                          print(card.data.belong_deck);
                          if (result == 1) {
                            Fluttertoast.showToast(msg: '同名カードは4枚まで追加できます。${card.data.card_name}');
                          } else if (result == 2) {
                            Fluttertoast.showToast(msg: 'メインデッキの上限に達しました。カードは60枚まで追加できます');
                          } else if (result == 3) {
                            Fluttertoast.showToast(msg: '同名カードは2枚まで追加できます。${card.data.card_name}');
                          } else if (result == 4) {
                            Fluttertoast.showToast(msg: 'GRゾーンの上限に達しました。カードは12枚まで追加できます');
                          } else if (result == 5) {
                            Fluttertoast.showToast(msg: '超次元ーンの上限に達しました。カードは8枚まで追加できます');
                          }
                        },
                      )),
                ],
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
                  SizedBox(height: deckAreaHeight + 48), // TabBarの高さ分を追加
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

  // メインデッキのエリアを構築するメソッド
  Widget _buildMainDeckArea(double deckAreaHeight, int crossAxisCount, double itemWidth) {
    const int mainDeckMax = 60; // デッキの最大枚数を60に変更

    return Consumer(builder: (context, ref, child) {
      final buildDeck = ref.watch(buildDeckProvider);
      final deckSize = buildDeck.mainDeck.length;

      // カード枚数に応じて行数を決定
      int numRows;
      if (deckSize <= 40) {
        numRows = 5;
      } else if (deckSize <= 48) {
        numRows = 6;
      } else if (deckSize <= 56) {
        numRows = 7;
      } else {
        numRows = 8;
      }

      // カードの高さとアスペクト比を計算
      final itemHeight = deckAreaHeight / numRows;
      final childAspectRatio = itemWidth / itemHeight;
      // グリッド全体のアイテム数を計算
      final totalGridItems = numRows * crossAxisCount;

      return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalGridItems,
          itemBuilder: (context, index) {
            if (index < buildDeck.mainDeck.length) {
              final card = buildDeck.mainDeck[index];
              final cardWidget = DeletableCardContainer(searchedCard: card, index: index, isReorderMode: _isReorderMode);
              Widget item = cardWidget;
              if (_isReorderMode) {
                item = Draggable<int>(
                  data: index,
                  feedback: SizedBox(
                    width: itemWidth,
                    height: itemHeight,
                    child: TestCardContainer(searchedCard: card, padding: 0),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: cardWidget,
                  ),
                  child: DragTarget<int>(
                    builder: (context, candidateData, rejectedData) {
                      return cardWidget;
                    },
                    onWillAcceptWithDetails: (fromIndex) {
                      return fromIndex.data != index;
                    },
                    onAcceptWithDetails: (fromIndex) {
                      ref.read(buildDeckProvider.notifier).swapCards(DeckType.main, fromIndex.data, index);
                    },
                  ),
                );
              }
              return KeyedSubtree(key: ValueKey(card.physical_id + index), child: item);
            } else {
              return Container(
                  margin: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(4.0),
                  ));
            }
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
          ));
    });
  }

  // 外部デッキのエリアを構築するメソッド
  Widget _buildExternalDeckArea(double deckAreaHeight, int crossAxisCount, double itemWidth) {
    const int uberDimensionDeckMax = 8;
    const int grDeckMax = 12;

    // ここはとりあえず固定のアスペクト比にしておくね！
    final childAspectRatio = 0.715;
    final itemHeight = itemWidth / childAspectRatio;


    return Column(
      children: [
        const Text("超次元ゾーン"),
        // 超次元デッキエリア
        Consumer(builder: (context, ref, child) {
          final buildDeck = ref.watch(buildDeckProvider);
          return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // itemCountは最大数の8に固定
              itemCount: uberDimensionDeckMax,
              itemBuilder: (context, index) {
                // インデックスが現在のデッキ枚数より少ない場合はカードを表示
                if (index < buildDeck.uberDimensionDeck.length) {
                  final card = buildDeck.uberDimensionDeck[index];
                  final cardWidget = DeletableCardContainer(searchedCard: card, index: index, isReorderMode: _isReorderMode);
                  Widget item = cardWidget;
                  if (_isReorderMode) {
                    item = Draggable<int>(
                      data: index,
                      feedback: SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: TestCardContainer(searchedCard: card, padding: 0),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: cardWidget,
                      ),
                      child: DragTarget<int>(
                        builder: (context, candidateData, rejectedData) {
                          return cardWidget;
                        },
                        onWillAcceptWithDetails: (fromIndex) {
                          return fromIndex.data != index;
                        },
                        onAcceptWithDetails: (fromIndex) {
                          ref.read(buildDeckProvider.notifier).swapCards(DeckType.uberDimension, fromIndex.data, index);
                        },
                      ),
                    );
                  }
                  return KeyedSubtree(key: ValueKey(card.physical_id + index), child: item);
                } else {
                  // そうでなければ、プレースホルダーのコンテナを表示
                  return Container(
                    margin: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  );
                }
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
              ));
        }),
        const Divider(
          height: 16,
          thickness: 4,
        ),
        const Text("GRゾーン"),
        // GRデッキエリア
        Consumer(builder: (context, ref, child) {
          final buildDeck = ref.watch(buildDeckProvider);
          return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // itemCountは最大数の12に固定
              itemCount: grDeckMax,
              itemBuilder: (context, index) {
                // インデックスが現在のデッキ枚数より少ない場合はカードを表示
                if (index < buildDeck.grDeck.length) {
                  final card = buildDeck.grDeck[index];
                  final cardWidget = DeletableCardContainer(searchedCard: card, index: index, isReorderMode: _isReorderMode);
                  Widget item = cardWidget;
                  if (_isReorderMode) {
                    item = Draggable<int>(
                      data: index,
                      feedback: SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: TestCardContainer(searchedCard: card, padding: 0),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: cardWidget,
                      ),
                      child: DragTarget<int>(
                        builder: (context, candidateData, rejectedData) {
                          return cardWidget;
                        },
                        onWillAcceptWithDetails: (fromIndex) {
                          return fromIndex.data != index;
                        },
                        onAcceptWithDetails: (fromIndex) {
                          ref.read(buildDeckProvider.notifier).swapCards(DeckType.gr, fromIndex.data, index);
                        },
                      ),
                    );
                  }
                  return KeyedSubtree(key: ValueKey(card.physical_id + index), child: item);
                } else {
                  // そうでなければ、プレースホルダーのコンテナを表示
                  return Container(
                    margin: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  );
                }
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
              ));
        }),

        const Divider(
          height: 16,
          thickness: 4,
        ),
        // ゲーム開始時にバトルゾーンにあるカードエリア
        Container(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Consumer(builder: (context, ref, child) {
            final buildDeck = ref.watch(buildDeckProvider);
            return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: buildDeck.beginning.length,
                itemBuilder: (context, index) {
                  final card = buildDeck.beginning[index];
                  final cardWidget = DeletableCardContainer(searchedCard: card, index: index, isReorderMode: _isReorderMode);
                  Widget item = cardWidget;
                  return KeyedSubtree(key: ValueKey(card.physical_id + index), child: item);
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                ));
          }),
        ),
      ],
    );
  }
  // 保存ダイアログを表示するメソッド
  Future<void> _showSaveDialog(BuildContext context, WidgetRef ref, {required buildMode}) async{
    final formKey = GlobalKey<FormState>();
    final deckNameController = TextEditingController(text: ref.read(buildDeckProvider).deckName);

    // ダイアログの状態を保持する変数
    String? selectedFormat = ref.read(buildDeckProvider).deckFormat;
    String? selectedLevel = ref.read(buildDeckProvider).deckLevel;
    // ドロップダウンの選択肢
    final formatItems = ['オリジナル', 'アドバンス', '殿堂ゼロ'];
    final levelItems = ['トーナメント', 'カジュアル', 'コンセプト'];
    // Providerから取得した値が選択肢にない場合はnullに設定し、エラーを防ぐ
    if (selectedFormat != null && !formatItems.contains(selectedFormat)) {
      selectedFormat = null;
    }
    if (selectedLevel != null && !levelItems.contains(selectedLevel)) {
      selectedLevel = null;
    }

    final bool? success = await showDialog(
      context: context,
      barrierDismissible: false, // ダイアログ外をタップしても閉じない
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('デッキの保存'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: deckNameController,
                        decoration: const InputDecoration(labelText: 'デッキ名 *'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'デッキ名を入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedFormat,
                        decoration: const InputDecoration(labelText: 'フォーマット'),
                        items:formatItems
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedFormat = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedLevel,
                        decoration: const InputDecoration(labelText: 'レベル'),
                        items: levelItems
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedLevel = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('キャンセル'),
                  onPressed: () {
                    // Providerの値を更新せずにダイアログを閉じる
                    Navigator.of(dialogContext).pop(false);
                  },
                ),
                ElevatedButton(
                  child: const Text('保存'),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      // Providerの値を更新
                      ref.read(buildDeckProvider.notifier).updateDeckInfo(
                        name: deckNameController.text,
                        format: selectedFormat,
                        level: selectedLevel,
                      );

                      late bool success;
                      // 保存処理
                      if(buildMode == 'CREATE') {
                        success = await ref.read(buildDeckProvider.notifier).saveDeck();
                      }else if(buildMode == 'EDIT'){
                        success = await ref.read(buildDeckProvider.notifier).updateDeck();
                      }

                      if (success) {
                        // 保存成功
                        Navigator.of(dialogContext).pop(true);
                      } else {
                        Navigator.of(dialogContext).pop(false);
                        // 保存失敗
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('デッキの保存に失敗しました')),
                        );
                      }
                    }
            },
                ),
              ],
            );
          },
        );
      },
    );
    // デッキを保存してダイアログを閉じたとき、デッキリストに戻る
    if(success == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }
}
