import 'package:animations/animations.dart';
import 'package:dml/provider/build_deck_provider.dart';
import 'package:dml/provider/search_param_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../SubScreen/searchCardScreen.dart';
import '../provider/search_result_provider.dart';
import '../source/card_data.dart';
import '../widgets/deck_Information.dart';
import '../widgets/searched_card_container.dart';

double deviceHeight = 0.0;
double deviceWidth = 0.0;

class BuilderScreen extends StatelessWidget {
  const BuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buildDeckProvider =
    Provider.of<BuildDeckProvider>(context, listen: false);

    return Consumer<BuildDeckProvider>(
        builder: (context, buildDeck, child) =>
            Scaffold(
              key: ValueKey('buildModeOff'),
              appBar: AppBar(
                title: const Text('デッキ一覧'),
              ),
              floatingActionButton: SpeedDial(
                  animatedIcon: AnimatedIcons.menu_close,
                  overlayColor: Colors.black,
                  overlayOpacity: 0.7,
                  spacing: 16,
                  children: [
                    SpeedDialChild(
                        child: const Icon(Icons.copy_rounded),
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
                        onTap: () =>
                        {
                          debugPrint('copy at'),
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return BuildDeckScreen();
                          }))
                        }),
                    SpeedDialChild(
                      child: const Icon(Icons.create_rounded),
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
                      onTap: () =>
                      {
                        debugPrint('create new'),
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
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
            ));
  }
}

class BuildDeckScreen extends StatelessWidget {
  BuildDeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 検索結果のProvider
    final searchResults =
    Provider.of<SearchResultsProvider>(context, listen: false);

    // 検索条件のパラメータ
    SearchParamProvider searchParam =
    Provider.of<SearchParamProvider>(context, listen: false);
    // Future.microtask(() {
    //   searchParam.resetAll();
    // });

    // 作為成中のデッキのProvider
    final buildDeckProvider = Provider.of<BuildDeckProvider>(context, listen: false);


    //画面サイズ
    deviceHeight = MediaQuery
        .of(context)
        .size
        .height;
    deviceWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('デッキ作る画面'),
        leading: IconButton(
            onPressed: () => {Navigator.pop(context)},
            icon: const Icon(Icons.arrow_back)),
        actions: [
          IconButton(
              onPressed: (){buildDeckProvider.resetDeck;}, icon: const Icon(Icons.clear_all_rounded)),
          IconButton(onPressed: () => {}, icon: const Icon(Icons.save_rounded)),
        ],
      ),
      body: Column(spacing: 10, children: [
        Flexible(
            child: Consumer<BuildDeckProvider>(
              builder: (context, buildDeck, child) =>
                  SingleChildScrollView(
                      child: VisibilityDetector(
                          key: const Key('deckLibrary'),
                          onVisibilityChanged: (VisibilityInfo info) {
                            //info.visibleFraction = 画面が表示されてる割合。１が最大
                            print(info.visibleFraction);
                          },
                          child: DragTarget<SearchCard>(
                            onAcceptWithDetails: (target) =>
                            {buildDeck.addDeck(target.data)},
                            builder: (context, candidateData, rejectedData) =>
                                Container(
                                    color: Colors.blueGrey,
                                    width: double.infinity,
                                    height: deviceWidth * 7 / 8,
                                    child: GridView.builder(
                                      itemCount: buildDeck.deck.length,
                                      itemBuilder: (context, index) {
                                        return TestCardContainer(
                                            searchedCard: buildDeck.deck[index],
                                            padding: 1,);
                                      },
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 8,
                                          childAspectRatio: 0.715,)
                                  // const Align(
                                  //   alignment: Alignment.center,
                                  //   child: Text('デッキのカードが表示される所'),
                                  // ),
                                ),
                          )
    ),
    ),
    ),
        ),),
        Container(
          color: Colors.blueGrey,
          width: double.infinity,
          height: deviceWidth * 2.8 / 8,
          child: FutureBuilder(
              future: searchResults.search_name(searchParam),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                return Consumer<SearchResultsProvider>(
                    builder: (context, searchResults, child) {
                      return Scrollbar(
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              return DraggableCardContainer(
                                  searchedCard: searchResults.results[index],
                                  height: deviceWidth * 2.8 / 8,
                                  width: deviceWidth * 2 / 8);
                            },
                          ));
                    });
              }),
        ),
        Consumer<SearchParamProvider>(
          builder: (context, searchParam, child) =>
              TextFormField(
                controller: searchParam.nameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (text) {
                  searchParam.setName(text);
                  searchResults.search_name(searchParam);
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "カード名で検索",
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  suffixIcon: OpenContainer(
                    transitionDuration: const Duration(milliseconds: 350),
                    closedElevation: 0,
                    closedShape: const CircleBorder(),
                    closedColor: Colors.transparent,
                    closedBuilder:
                        (BuildContext context, VoidCallback openContainer) {
                      return const Icon(Icons.tune_outlined);
                    },
                    openBuilder: (BuildContext context,
                        VoidCallback closeContainer,) {
                      return SearchField(
                        context: context,
                        searchFunc: searchResults.search_name,
                      );
                    },
                  ),
                ),
              ),
        )
      ]),
      // floatingActionButton:FloatingActionButton(onPressed: null,child: Icon(Icons.save),)
    );
  }
}
