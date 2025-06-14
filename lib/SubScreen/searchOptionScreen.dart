import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/search_param_provider.dart';
import '../provider/search_result_provider.dart';

class SearchOption extends StatelessWidget {
  SearchOption({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchResultsProvider>(
      builder: (context, searchResultsDialog, child) {
        double currentColumn = searchResultsDialog.displayColumn.toDouble();
        return Container(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 3,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: Column(spacing: 10, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('現在の列数: ${searchResultsDialog.displayColumn}列'),
                    Slider(
                      value: currentColumn,
                      min: 2,
                      max: 4,
                      divisions: 2,
                      // 2, 3, 4の3つの選択肢
                      label: currentColumn.round().toString(),
                      onChanged: (double value) {
                        // スライダーの値を変更したらすぐに反映
                        // setStateでConsumerを再ビルドさせる
                        searchResultsDialog.setDisplayColumn(value.round());
                      },
                    ),
                  ]),
                ),
              ),
              Consumer<SearchParamProvider>(
                builder: (context, searchParam, child) => Card(
                  elevation: 3,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Column(spacing: 10, children: [
                      SwitchListTile(
                          title: const Text('同名カードを表示する'),
                          value: searchParam.sameName,
                          onChanged: (value) {
                            searchParam.setSameName(value);
                          }),
                    ]),
                  ),
                ),
              ),
              Consumer<SearchParamProvider>(
                builder: (context, searchParam, child) => Card(
                  elevation: 3,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Column(spacing: 10, children: [
                      SwitchListTile(
                        title: const Text('あいまい検索を有効にする'),
                        value: searchParam.fuzzySearch,
                        onChanged: (value) {
                          searchParam.setFuzzySearch(value);
                        },
                      ),
                    ]),
                  ),
                ),
              ),
              Consumer<SearchParamProvider>(
                  builder: (context, searchParam, child) => Card(
                    elevation: 3,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: Column(spacing: 10, children: [
                        Text('検索結果のソート順')
                          ]
                      )
                    ),
                  ),
              )
            ],
          ),
        );
      },
    );
  }
}
