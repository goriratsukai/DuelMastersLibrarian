import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../widgets/deck_Information.dart';
import '../SubScreen/builder.dart';

double deviceHeight = 0.0;
double deviceWidth = 0.0;

class DeckListScreen extends StatelessWidget {
  const DeckListScreen({super.key});

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey('buildModeOff'),
      // appBar: AppBar(
      //   title: const Text('デッキ一覧'),
      // ),
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
            onTap: () => {
              debugPrint('copy at'),
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return BuildDeckScreen();
              }))
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
          onTap: () => {
            debugPrint('create new'),
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return BuildDeckScreen();
            }))
          },
        ),
      ]),
      body: Scrollbar(
          key: ValueKey('buildModeOff'),
          child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return deckInfoContainer();
              })),
    );
  }
}
