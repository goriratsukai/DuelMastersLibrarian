import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DownloadNotifier extends AsyncNotifier<bool?> {
  @override
  Future<bool?> build() async {
    // これで、初期化完了時のstateは AsyncData(null) になる
    return null;
  }

  Future<void> downloadFile() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      String url = dotenv.get('CARD_DATABASE_URL');
      String filename = dotenv.get('CARD_DATABASE_FILE_NAME');
      Directory downloadDirectory = await getApplicationDocumentsDirectory();
      String dir = downloadDirectory.path;

      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        File file = File('$dir/$filename');
        await file.writeAsBytes(response.bodyBytes);
        return true;
      } else {
        throw Exception('httpエラー：${response.statusCode}');
      }
    });
  }
}

final downloadProvider = AsyncNotifierProvider<DownloadNotifier, bool?>(DownloadNotifier.new);

class OptionScreen extends ConsumerWidget {
  const OptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    ref.listen(downloadProvider, (previous, next) {
      // エラーが発生した場合はエラーメッセージを表示
      if(next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました：${next.error.toString()}'),
          ),
        );
      }
      // stateに値があって(hasValue)、その値がtrueの場合のみ完了メッセージを表示
      // これで、ダウンロード成功時だけをピンポイントで検知できる！
      if (next.hasValue && next.value == true) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
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
              // ここの部分は特に変更しなくても大丈夫！
              ref.watch(downloadProvider).when(
                loading: () => const LinearProgressIndicator(),
                error: (error, stackTrace) => Text('エラーが発生しました：$error'),
                data: (data) => const SizedBox.shrink(),
              )
            ]
        ),
      ),
    );
  }
}