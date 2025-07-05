import 'package:dml/provider/search_param_provider.dart';
import 'package:dml/provider/search_result_provider.dart';
import 'package:dml/provider/build_deck_provider.dart';
import 'package:dml/src/deck_list.dart';
import 'package:dml/src/home.dart';
import 'package:dml/src/links.dart';
import 'package:dml/src/option.dart';
import 'package:dml/src/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animations/animations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'util.dart';
import 'theme.dart';

// 現在の画面StateProvider
final bottomNavigatorBarProvider = StateProvider<int>((ref) => 1);

void main() async {
  await dotenv.load(fileName: 'assets/.env');
  WidgetsFlutterBinding.ensureInitialized(); // プラグイン初期化
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    // Retrieves the default theme for the platform
    //TextTheme textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'librarian',
      theme: ThemeData(
          // brightness: brightness,
          useMaterial3: true,
          // ライトモード固定
          // colorScheme: brightness == Brightness.light
          //     ? MaterialTheme.lightScheme()
          //     : MaterialTheme.darkScheme(),
          colorScheme: MaterialTheme.lightScheme(),
          fontFamily: 'NotoSansJP',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'NotoSansJP'),
          )),
      // home: const BottomNavigation(),
      // supportedLocales: const [
      //   Locale('ja', 'JP'),
      // ],
      routes: {
        '/':(context) => const BottomNavigation(),
        '/deck_list': (context) => const DeckListScreen(),
        '/search': (context) => const SearchScreen(),
        '/option': (context) => const OptionScreen(),
        '/links': (context) => const LinksScreen(),
      },
    );
  }
}

class BottomNavigation extends ConsumerWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var screen = [
      const DeckListScreen(),
      const SearchScreen(),
      const OptionScreen(),
      const LinksScreen(),
    ];

    final selectedIndex = ref.watch(bottomNavigatorBarProvider);

    // ダイアログが出ない。要修正
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) {
            AlertDialog(
              title: const Text('終了しますか？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // 画面を閉じずに戻る
                  child: const Text('キャンセル'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // アプリを終了する
                  child: const Text('終了'),
                ),
              ],
            );
            return;
          }
        },
        child: Scaffold(
          body: SafeArea(child: screen[selectedIndex]),
          bottomNavigationBar: NavigationBar(
              height: 72,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (int index) {
                ref.read(bottomNavigatorBarProvider.notifier).state = index;
              },
              indicatorColor: Theme.of(context).colorScheme.primaryFixed,
              selectedIndex: ref.read(bottomNavigatorBarProvider.notifier).state,
              destinations: const <Widget>[
                NavigationDestination(selectedIcon: Icon(Icons.widgets), icon: Icon(Icons.widgets_outlined), label: 'マイデッキ'),
                NavigationDestination(selectedIcon: Icon(Icons.sim_card), icon: Icon(Icons.sim_card_outlined), label: 'カード検索'),
                NavigationDestination(selectedIcon: Icon(Icons.settings), icon: Icon(Icons.settings_outlined), label: '設定'),
                NavigationDestination(selectedIcon: Icon(Icons.language_sharp), icon: Icon(Icons.language_outlined), label: 'リンク'),
              ]),
        ));
  }
}
