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
                imageUrl:
                '${dotenv.get('CARD_IMAGE_URL')}${searchedCard.image_name}.webp',
                    // 'https://d24xxkmtso62vi.cloudfront.net/images/${searchedCard.image_name}.jpg',
                placeholder: (context, url) => const Card(
                    borderOnForeground: true,
                    child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )),
                errorWidget: (context, url, error) => Card(
                    borderOnForeground: true,
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(searchedCard.card_name))),
              )),
        ),
        child: Padding(
            padding: const EdgeInsets.all(1),
            child: CachedNetworkImage(
              height: height,
              width: width,
              imageUrl:
              '${dotenv.get('CARD_IMAGE_URL')}${searchedCard.image_name}.webp',

              // 'https://d24xxkmtso62vi.cloudfront.net/images/${searchedCard.image_name}.webp',
              // imageBuilder: (context, image){if()},
              placeholder: (context, url) => const Card(
                  borderOnForeground: true,
                  child: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )),
              errorWidget: (context, url, error) => Card(
                  borderOnForeground: true,
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(searchedCard.card_name))),
            )));
  }
}

class TestCardContainer extends StatelessWidget {
  const TestCardContainer({super.key,
    required this.searchedCard,
    required this.padding,
  });

  final SearchCard searchedCard;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(padding),
        child: CachedNetworkImage(
          imageUrl:
          '${dotenv.get('CARD_IMAGE_URL')}${searchedCard.image_name}.webp',

          // 'https://d24xxkmtso62vi.cloudfront.net/images/${searchedCard.image_name}.webp',
          // imageBuilder: (context, image){if()},
          placeholder: (context, url) => const Card(
              borderOnForeground: true,
              child: Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )),
          errorWidget: (context, url, error) => Card(
              borderOnForeground: true,
              child: Align(
                  alignment: Alignment.center,
                  child: Text(searchedCard.card_name))),
        )

        // Image.network(
        //   'https://dm.takaratomy.co.jp/wp-content/card/cardimage/${searchedCard.image_name}.jpg',
        //   errorBuilder: (context, object, stackTrace) {
        //     return Card(
        //         borderOnForeground: true,
        //         child:Align(alignment: Alignment.center,child:
        //         Text(searchedCard.card_name)));
        //   },
        // )
        );
  }
}

// class JsonCacheManager extends CacheManager with ImageCacheManager{
//   static const key = 'libCachedImageData';
//
//   final JsonCacheManager _instance = JsonCacheManager(
//     Config(
//       key,
//       stalePeriod: const Duration(days: 30),
//       maxNrOfCacheObjects: 500,
//       repo: JsonCacheInfoRepository(databaseName: key),
//       fileSystem: IOFileSystem(key),
//       fileService: HttpFileService(),
//     ),
//   );
//
//   JsonCacheManager(super.config);
// }
