import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../model/deck.dart';

class deckInfoContainer extends StatelessWidget {
  const deckInfoContainer({
    super.key,
    required this.deck,
  });

  final Deck deck;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          deck.deckName, // デッキ名を表示
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('フォーマット: ${deck.deckFormat ?? '未設定'}'),
            Text('レベル: ${deck.deckLevel ?? '未設定'}'),
            Text('枚数: メイン ${deck.deckCountMain} / GR ${deck.deckCountGr} / 超次元 ${deck.deckCountUb}'),
            const SizedBox(height: 4),
            Text(
              '更新日: ${DateFormat('yyyy/MM/dd HH:mm').format(deck.updatedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO: デッキ詳細画面への遷移処理
        },
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   //画面サイズ
  //   double deviceHeight = MediaQuery.of(context).size.height;
  //   double deviceWidth = MediaQuery.of(context).size.width;
  //
  //   return Card(
  //       margin:
  //           EdgeInsets.fromLTRB(deviceWidth * 0.05, deviceWidth * 0.05, deviceWidth * 0.05, 0),
  //     child: SizedBox(
  //       width: double.infinity,
  //       child: Column(
  //         children: [
  //           const Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Padding(
  //                   padding: EdgeInsets.all(5),
  //                   child: Text('デッキ名'),
  //                 ),
  //               ]),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Container(
  //                 color: Colors.redAccent,
  //                 width: deviceWidth * 0.2,
  //                 height: deviceWidth * 0.125,
  //               ),
  //               Container(
  //                 color: Colors.blueAccent,
  //                 width: deviceWidth * 0.2,
  //                 height: deviceWidth * 0.125,
  //               ),
  //               Container(
  //                 color: Colors.greenAccent,
  //                 width: deviceWidth * 0.2,
  //                 height: deviceWidth * 0.125,
  //               ),
  //               Container(
  //                 color: Colors.deepPurpleAccent,
  //                 width: deviceWidth * 0.2,
  //                 height: deviceWidth * 0.125,
  //               )
  //             ],
  //           ),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: [
  //               IconButton(
  //                   onPressed: () {},
  //                   icon: const FaIcon(
  //                     FontAwesomeIcons.solidPenToSquare,
  //                     size: 20,
  //                   )),
  //               IconButton(
  //                   onPressed: () {},
  //                   icon: const FaIcon(
  //                     FontAwesomeIcons.circleInfo,
  //                     size: 20,
  //                   )),
  //               IconButton(
  //                   onPressed: () {},
  //                   icon: const FaIcon(
  //                     FontAwesomeIcons.solidNoteSticky,
  //                     size: 20,
  //                   )),
  //               IconButton(
  //                   onPressed: () {},
  //                   icon: const FaIcon(
  //                     FontAwesomeIcons.solidTrashCan,
  //                     size: 20,
  //                   )),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
