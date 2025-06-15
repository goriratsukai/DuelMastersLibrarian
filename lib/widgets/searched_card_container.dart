import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dml/source/card_data.dart';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchedCardContainer extends StatelessWidget {
  const SearchedCardContainer({
    super.key,
    required this.searchedCard,
  });

  final SearchCard searchedCard;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF6C87FF),
              borderRadius: BorderRadius.all(
                Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Text(searchedCard.card_name),
                Text(searchedCard.object_id.toString()),
              ],
            )));
  }
}

class DraggableCardContainer extends StatelessWidget {
  const DraggableCardContainer({
    super.key,
    required this.searchedCard,
    required this.height,
    required this.width,
  });

  final SearchCard searchedCard;
  final double height;
  final double width;

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
                // 'https://d24xxkmtso62vi.cloudfront.net/images/${searchedCard.image_name}.jpg',
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
            child: CachedNetworkImage(
              height: height,
              width: width,
              imageUrl: '${dotenv.get('CARD_IMAGE_URL')}${searchedCard.image_name}.webp',

              // 'https://d24xxkmtso62vi.cloudfront.net/images/${searchedCard.image_name}.webp',
              // imageBuilder: (context, image){if()},
              placeholder: (context, url) => const Card(
                  borderOnForeground: true,
                  child: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )),
              errorWidget: (context, url, error) =>
                  Card(borderOnForeground: true, child: Align(alignment: Alignment.center, child: Text(searchedCard.card_name))),
            )));
  }
}

class TestCardContainer extends StatelessWidget {
  const TestCardContainer({
    super.key,
    required this.searchedCard,
    required this.padding,
  });

  final SearchCard searchedCard;
  final double padding;

  @override
  Widget build(BuildContext context) {
    // GestureDetectorでタップイベントを検知するよ！
    return Padding(
      padding: EdgeInsets.all(padding),
      child: GestureDetector(
        onTap: () {
          // フルスクリーンダイアログを表示するよ！
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FullScreenImageDialog(
                imageUrl: '${dotenv.get('CARD_IMAGE_URL')}${searchedCard.image_name}.webp',
                heroTag: searchedCard.image_name, // ここでheroTagを指定するよ
              ),
            ),
          );
        },
        child: Hero(
          // Heroウィジェットで囲むよ！
          tag: searchedCard.image_name, // heroTagはsearchedCard.image_nameにするよ
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
      // backgroundColor: Colors.transparent,
      // backgroundColor: Colors.white.withAlpha(0), // 背景は黒にすると画像が映えるよ！
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // タップしたら戻るよ
          },
          child: Hero(
            // ここもHeroウィジェットで囲むの忘れずに！
            tag: heroTag, // heroTagはTestCardContainerと同じものを使うよ
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
              errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
