import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../helper/database_helper.dart';
import '../helper/image_generator.dart';
import '../model/deck.dart';
import '../widgets/deck_Information.dart';
import '../SubScreen/builder.dart';

double deviceHeight = 0.0;
double deviceWidth = 0.0;

class DeckListScreen extends ConsumerStatefulWidget {
  const DeckListScreen({super.key});

  @override
  ConsumerState<DeckListScreen> createState() => _DeckListScreenState();
}


class _DeckListScreenState extends ConsumerState<DeckListScreen> {
  late Future<List<Deck>> _decksFuture;

  @override
  void initState() {
    _loadDecks();
    super.initState();
  }

  // DBからデッキリストを読み込む
  void _loadDecks() {
    setState(() {
      _decksFuture = DatabaseHelper.instance.getDecks();
    });
  }

  @override
  Widget build(BuildContext context) {

    final isSaveDeckImage = ref.watch(isSaveDeckImageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('デッキ一覧'),
      ),
      // FutureBuilderを使って非同期処理の結果に応じてUIを構築
      body:
      Stack(children: [
      FutureBuilder<List<Deck>>(
        future: _decksFuture,
        builder: (context, snapshot) {
          // データ取得待ち
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // エラー発生
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }
          // データなし
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('保存されているデッキはありません。'));
          }

          // データ取得成功
          final decks = snapshot.data!;
          return ListView.builder(
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return deckInfoContainer(deck: deck); // DeckInformationにDeckオブジェクトを渡す
            },
          );
        },
      ),
      if(isSaveDeckImage)
        // Expanded(child:
          Container(
            color: Colors.black.withOpacity(0.5),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'デッキ画像を保存中',
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
              )
            // ),
          ),)
      ],),
      floatingActionButton:
      SpeedDial(animatedIcon: AnimatedIcons.menu_close, overlayColor: Colors.black, overlayOpacity: 0.7, spacing: 16, children: [
        SpeedDialChild(
            child: Icon(Icons.copy_rounded),
            labelWidget: const Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Text(
                'コピーして作成',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            backgroundColor: Colors.amber,
            onTap: () async => {
              debugPrint('copy at'),
              //todo デッキを選択して、loadDeckを呼び出す処理を追加
              await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return BuildDeckScreen(buildMode: 'CREATE');
              })).then((_) => _loadDecks())
            }),
        SpeedDialChild(
          child: Icon(Icons.create_rounded),
          labelWidget: const Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Text(
              '新規作成',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor: Colors.amber,
          onTap: () async => {
            debugPrint('create new'),
            await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return BuildDeckScreen(buildMode: 'CREATE');
            })).then((_) => _loadDecks())
          },
        ),
      ]),
    );
  }
}
