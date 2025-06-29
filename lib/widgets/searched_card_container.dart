import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dml/source/card_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../provider/build_deck_provider.dart';

class DeletableCardContainer extends ConsumerStatefulWidget {
  const DeletableCardContainer({
    super.key,
    required this.searchedCard,
    required this.index, // デッキリストの何番目かを受け取る
    required this.isReorderMode // 並び替えモードかどうか
  });

  final SearchCard searchedCard;
  final int index;
  final bool isReorderMode;

  @override
  ConsumerState<DeletableCardContainer> createState() => _DeletableCardContainerState();
}

class _DeletableCardContainerState extends ConsumerState<DeletableCardContainer> {
  double _dragY = 0.0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {

    // 上下ドラッグ時の透明度を計算
    final double opacity = 1.0 - (_dragY / 50).clamp(0.0,0.5);

    return GestureDetector(
      // 垂直方向のドラッグ開始を検知
      onVerticalDragStart: widget.isReorderMode ? null :(details) {
        setState(() {
          _isDragging = true;
        });
      },
      // ドラッグ中の動きを検知
      onVerticalDragUpdate: widget.isReorderMode ? null :(details) {
        setState(() {
          if (_dragY > -50 && _dragY < 50) {
            _dragY += details.delta.dy;
          } else if (_dragY > 50) {
            if (details.delta.dy < 0) {
              _dragY += details.delta.dy;
            }
          } else if (_dragY < -50) {
            if (details.delta.dy > 0) {
              _dragY += details.delta.dy;
            }
          }
        });
      },
      // ドラッグ終了を検知
      onVerticalDragEnd: widget.isReorderMode ? null :(details) {
        // 下向きに一定距離（今回は50px）以上ドラッグされていたら削除
        if (_dragY > 50) {
          // Providerを呼び出してカードを削除！
          ref.read(buildDeckProvider.notifier).removeDeck(widget.searchedCard,widget.index);
          // 削除したことをユーザーに通知
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.searchedCard.card_name} をデッキから削除しました'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        // 上向きに一定距離（今回は50px）以上ドラッグされていたらデッキに追加
        if(_dragY < -50) {
          final result = ref.read(buildDeckProvider.notifier).addDeck(ref.read(buildDeckProvider.notifier).getCardFromDeck(widget.searchedCard, widget.index));
          if(result == 1) {
            Fluttertoast.showToast(msg: '同名カードは4枚まで追加できます。${widget.searchedCard.card_name}');
          } else if(result == 2) {
            Fluttertoast.showToast(msg: 'メインデッキの上限に達しました。カードは60枚まで追加できます');
          }
        }
        // ドラッグ終了したら、位置を元に戻す
        setState(() {
          _dragY = 0;
          _isDragging = false;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: _isDragging ? 0 : 200),
        curve: Curves.easeOut,
        // ドラッグした分だけカードをY方向に動かす
        transform: Matrix4.translationValues(0, _dragY, 0),
        child: Opacity(
          opacity: opacity,
          child: TestCardContainer(
            searchedCard: widget.searchedCard,
            padding: 2,
            heroOffset: widget.index.toString(),
          ),
        ),
      ),
    );
  }
}

class DraggableCardContainer extends StatelessWidget {
  const DraggableCardContainer({
    super.key,
    required this.searchedCard,
    required this.height,
    required this.width,
    required this.padding,
  });

  final SearchCard searchedCard;
  final double height;
  final double width;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Draggable(
      affinity: Axis.vertical,
      data: searchedCard,
      feedback: Padding(
        padding: const EdgeInsets.all(3),
        child: Opacity(
            opacity: 0.5,
            child: CachedNetworkImage(
              height: height,
              width: width,
              imageUrl: '${dotenv.get('CARD_IMAGE_URL')}${searchedCard.image_name}.webp',
              placeholder: (context, url) => const Card(
                  borderOnForeground: true,
                  child: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )),
              errorWidget: (context, url, error) =>
                  Card(borderOnForeground: true, child: Align(alignment: Alignment.center, child: Text(searchedCard.card_name))),
            )),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: GestureDetector(
          onTap: () {
            // フォーカスを取り除く
            FocusScope.of(context).unfocus();
            // フルスクリーンで画像を表示
            Navigator.of(context)
                .push(PageRouteBuilder(
              opaque: false,
              barrierDismissible: true,
              pageBuilder: (context, _, __) {
                return FullScreenImageDialog(
                  imageUrl: '${dotenv.get('CARD_IMAGE_URL')}${searchedCard.image_name}.webp',
                  heroTag: '${searchedCard.image_name}_b', // ここでheroTagを指定するよ
                );
              },
            ))
                // フルスクリーン表示を解除したあと、自動でフォーカスを取る動作を抑制
                .then((_) {
              FocusScope.of(context).requestFocus(FocusNode());
            });
          },
          child: Hero(
            tag: '${searchedCard.image_name}_b',
            child: CachedNetworkImage(
              height: height,
              width: width,
              imageUrl: '${dotenv.get('CARD_IMAGE_URL')}${searchedCard.image_name}.webp',
              placeholder: (context, url) => const Card(
                  borderOnForeground: true,
                  child: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )),
              errorWidget: (context, url, error) =>
                  Card(borderOnForeground: true, child: Align(alignment: Alignment.center, child: Text(searchedCard.card_name))),
            ),
          ),
        ),
      ),
    );
  }
}

class TestCardContainer extends StatelessWidget {
  const TestCardContainer({
    super.key,
    required this.searchedCard,
    required this.padding,
    this.heroOffset = '',
  });

  final SearchCard searchedCard;
  final double padding;
  final String heroOffset;

  @override
  Widget build(BuildContext context) {
    // GestureDetectorでタップイベントを検知するよ！
    return Padding(
      padding: EdgeInsets.all(padding),
      child: GestureDetector(
        onTap: () {
          // フォーカスを取り除く
          FocusScope.of(context).unfocus();
          // フルスクリーンダイアログを表示するよ！
          Navigator.of(context)
              .push(PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            pageBuilder: (context, _, __) {
              return FullScreenImageDialog(
                imageUrl: '${dotenv.get('CARD_IMAGE_URL')}${searchedCard.image_name}.webp',
                heroTag: '${searchedCard.image_name}$heroOffset',
              );
            },
          ))
              // フルスクリーン表示を解除したあと、自動でフォーカスを取る動作を抑制
              .then((_) {
            FocusScope.of(context).requestFocus(FocusNode());
          });
        },
        child: Hero(
          // Heroウィジェットで囲むよ！
          tag: '${searchedCard.image_name}$heroOffset', // heroTagはsearchedCard.image_nameにするよ
          child: CachedNetworkImage(
            imageUrl: '${dotenv.get('CARD_IMAGE_URL')}${searchedCard.image_name}.webp',
            placeholder: (context, url) => const Card(
                borderOnForeground: true,
                child: Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                )),
            errorWidget: (context, url, error) =>
                Card(borderOnForeground: true, child: Align(alignment: Alignment.center, child: Text(searchedCard.card_name))),
          ),
        ),
      ),
    );
  }
}

// フルスクリーンで画像を表示するための新しいWidgetを作るよ！
class FullScreenImageDialog extends StatelessWidget {
  const FullScreenImageDialog({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  final String imageUrl;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withAlpha(150), // 背景を半透明の黒にする
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // タップしたら戻るよ
          },
          child: Hero(
            // ここもHeroウィジェットで囲むの忘れずに！
            tag: heroTag, // heroTagはTestCardContainerと同じものを使うよ
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              // boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.white)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
