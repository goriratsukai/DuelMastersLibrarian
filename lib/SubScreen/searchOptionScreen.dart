import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

import '../provider/search_param_provider.dart';
import '../provider/search_result_provider.dart';

class SearchOption extends ConsumerWidget {
  SearchOption({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // SearchParamProviderの状態を監視
    final searchParamState = ref.watch(searchParamProvider);
    final searchParamNotifier = ref.read(searchParamProvider.notifier);
    // displayColumnProviderの状態を監視
    final displayColumnState = ref.watch(displayColumnProvider);

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
                Text('現在の列数: $displayColumnState列'),
                SliderTheme(
                  data: const SliderThemeData(
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 14),
                  ),
                  child: Slider(
                    value: displayColumnState.toDouble(),
                    min: 2,
                    max: 4,
                    divisions: 2,
                    // 2, 3, 4の3つの選択肢
                    label: displayColumnState.round().toString(),
                    onChanged: (double value) {
                      // スライダーの値を変更したらすぐに反映
                      ref.read(displayColumnProvider.notifier).state = value.round();
                    },
                  ),
                ),
              ]),
            ),
          ),
          Card(
            elevation: 3,
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Column(spacing: 10, children: [
                SwitchListTile(
                    title: const Text('同名カードを表示する'),
                    value: searchParamState.sameName,
                    onChanged: (value) {
                      ref.read(searchParamProvider.notifier).setSameName(value);
                    }),
              ]),
            ),
          ),
          Card(
            elevation: 3,
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Column(spacing: 10, children: [
                SwitchListTile(
                  title: const Text('あいまい検索を有効にする'),
                  value: searchParamState.fuzzySearch,
                  onChanged: (value) {
                    ref.read(searchParamProvider.notifier).setFuzzySearch(value);
                  },
                ),
              ]),
            ),
          ),
          Card(
            elevation: 3,
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: [
                  Text(
                    '検索結果の並び順',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ToggleButtons(
                    onPressed: (int index) {
                      searchParamNotifier.setSortKey(index);
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedBorderColor: Theme.of(context).colorScheme.primary,
                    selectedColor: Colors.white,
                    fillColor: Theme.of(context).colorScheme.primary,
                    color: Theme.of(context).colorScheme.primary,
                    constraints: const BoxConstraints(minHeight: 40.0, minWidth: 100.0),
                    isSelected: searchParamState.sortKey,
                    children: const <Widget>[
                      Text('新しい順'),
                      Text('パワー順'),
                      Text('コスト順'),
                    ],
                  ),
                  ToggleButtons(
                    onPressed: (int index) {
                      searchParamNotifier.setSortOrder(index);
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedBorderColor: Theme.of(context).colorScheme.secondary,
                    selectedColor: Colors.white,
                    fillColor: Theme.of(context).colorScheme.secondary,
                    color: Theme.of(context).colorScheme.secondary,
                    constraints: const BoxConstraints(
                      minHeight: 40.0,
                      minWidth: 150.0,
                    ),
                    isSelected: searchParamState.sortOrder,
                    children: const <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_upward, size: 18),
                          SizedBox(width: 8),
                          Text('昇順'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_downward, size: 18),
                          SizedBox(width: 8),
                          Text('降順'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
