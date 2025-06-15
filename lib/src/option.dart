import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DownloadNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // 初期化時はなにもしない
  }
  Future<void> downloadFile() async {
    // Stateをローディング状態にする
    state = const AsyncValue.loading();

    // try-catchで成功/失敗をハンドリング
    state = await AsyncValue.guard(() async {
      String url = dotenv.get('CARD_DATABASE_URL');
      String filename = dotenv.get('CARD_DATABASE_FILE_NAME');
      Directory downloadDirectory = await getApplicationDocumentsDirectory();
      String dir = downloadDirectory.path;

      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        File file = File('$dir/$filename');
        await file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('httpエラー：${response.statusCode}');
      }
    });
  }
}

// Provider
final downloadProvider = AsyncNotifierProvider<DownloadNotifier, void>(DownloadNotifier.new);

// 画面
class OptionScreen extends ConsumerWidget {
  const OptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    ref.listen(downloadProvider, (previous, next) {
      if(next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました：${next.error.toString()}'),
          ),
        );
      }
      if (next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('カードデータのダウンロードが完了しました'),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: deviceWidth * 0.9 * 0.1,
              margin: EdgeInsets.fromLTRB(
                deviceWidth * 0.05,
                10,
                deviceWidth * 0.05,
                10,
              ),
              child: ElevatedButton(
                onPressed: (){ref.read(downloadProvider.notifier).downloadFile();},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("カードデータをダウンロード"),
              ),
            ),

            ref.watch(downloadProvider).when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) => Text('エラーが発生しました：$error'),
              data: (data) => const SizedBox.shrink(),
            )
          ]
        ),
      ),
    );
  }
}

