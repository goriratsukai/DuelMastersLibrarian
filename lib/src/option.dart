import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DownloadProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

class OptionScreen extends StatelessWidget {
  const OptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> downloadFile() async {
      final downloadProvider = Provider.of<DownloadProvider>(context, listen: false);
      String url = dotenv.get('CARD_DATABASE_URL');
      String filename = dotenv.get('CARD_DATABASE_FILE_NAME');

      try {
        // ローディング開始
        downloadProvider.setLoading(true);

        // ダウンロード先の取得
        Directory downloadDirectory = await getApplicationDocumentsDirectory();
        String dir = downloadDirectory.path;

        // ファイルダウンロード
        http.Response response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          // ファイル保存
          File file = File('$dir/$filename');
          await file.writeAsBytes(response.bodyBytes);
          print('ファイルのダウンロードが完了しました：$dir/$filename');
          // 成功通知
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ファイルのダウンロードが完了しました：$dir/$filename')),
          );
        } else {
          print('httpエラー：${response.statusCode}');
          // HTTPエラー通知
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('HTTPエラー：${response.statusCode}')),
          );
        }
      } catch (e) {
        print('エラーが発生しました：$e');
        // エラー通知
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました：$e')),
        );
      } finally {
        // ローディング終了
        downloadProvider.setLoading(false);
      }
    }

    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

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
                onPressed: downloadFile,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("カードデータをダウンロード"),
              ),
            ),
            Consumer<DownloadProvider>(
              builder: (context, downloadProvider, child) {
                return downloadProvider.isLoading
                    ? CircularProgressIndicator()
                    : SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

