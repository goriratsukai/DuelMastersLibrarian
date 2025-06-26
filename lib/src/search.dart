import 'dart:io';

import 'package:animations/animations.dart';
import 'package:dml/provider/search_param_provider.dart';
import 'package:dml/provider/search_result_provider.dart';
import 'package:dml/widgets/searched_card_container.dart';
import 'package:flutter/material.dart';
import 'package:dml/source/card_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dml/theme.dart';

import 'package:dml/SubScreen/show_multipage_dialog.dart';

import '../SubScreen/searchOptionScreen.dart';

double deviceHeight = 0.0;
double deviceWidth = 0.0;

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    _nameController = TextEditingController(text: ref.read(searchParamProvider).name);
    super.initState();

  }


  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider.notifier);

    final asyncSearchResults = ref.watch(searchResultsProvider);

    ref.listen(searchParamProvider.select((value) => value.name), (_, next) {
      if (_nameController.text != next) {
        _nameController.text = next;
      }
    });

    //画面サイズ
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // FABを中央下部に配置
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
        body: asyncSearchResults.when(
          data: (results) {
            if (results.isEmpty) {
              return const Center(
                child: Text('検索結果はありません。'),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              itemCount: results.length + ref.watch(displayColumnProvider),
              itemBuilder: (context, index) {
                return results.length > index
                    ? TestCardContainer(searchedCard: results[index], padding: 5)

                    : SizedBox(
                        height: deviceWidth / ref.watch(displayColumnProvider) * 1.4,
                      );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: ref.watch(displayColumnProvider), childAspectRatio: 0.715),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
        ));
  }
}
