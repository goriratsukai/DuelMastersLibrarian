import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';

class ImageGenerator {
  // メソッド名を変更
  static Future<void> generateAndSaveDeckImage(String deckId, String deckName) async {
    try {
      // 1. DBからカード情報を取得 (変更なし)
      final cardInfos = await DatabaseHelper.instance.getDeckCardsForImage(deckId);
      if (cardInfos.isEmpty) {
        Fluttertoast.showToast(msg: "画像生成対象のカードがありません。");
        return;
      }

      // 2. カード画像のURLリストを作成 (変更なし)
      final imageUrls = cardInfos.map((info) => '${dotenv.get('CARD_IMAGE_URL')}${info['image_name']}.webp').toList();

      // 3. カード画像を非同期でダウンロード (変更なし)
      final List<Uint8List> imageBytesList = [];
      final cacheManager = DefaultCacheManager();
      for (String url in imageUrls) {
        try {
          // キャッシュからファイルを取得し、なければダウンロードする
          final file = await cacheManager.getSingleFile(url);
          imageBytesList.add(await file.readAsBytes());
        } catch (e) {
          print('画像の取得/読み込みに失敗しました: $url, エラー: $e');
          // 失敗した場合はスキップ
        }
      }

      // 4. 画像を生成 (変更なし)
      final generatedImage = await _createDeckImage(deckName, imageBytesList);
      if (generatedImage == null) return;

      // 5. 画像をPNG形式にエンコード
      final Uint8List pngBytes = Uint8List.fromList(img.encodePng(generatedImage));

      // 6. ギャラリーに画像を保存
      final result = await ImageGallerySaverPlus.saveImage(pngBytes,
          quality: 100, // 品質を100に設定
          name: "deck_${deckName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}" // ファイル名を指定
          );

      if (result['isSuccess']) {
        Fluttertoast.showToast(msg: "ギャラリーに画像を保存しました");
      } else {
        Fluttertoast.showToast(msg: "画像の保存に失敗しました");
      }
    } catch (e) {
      print('画像生成・保存中にエラーが発生しました: $e');
      Fluttertoast.showToast(msg: "エラーが発生しました: $e");
    }
  }

  // デッキ画像を生成する内部メソッド
  static Future<img.Image?> _createDeckImage(String deckName, List<Uint8List> imageBytesList) async {
    // --- 定数と計算部分を変更 ---
    const int crossAxisCount = 8;
    const int cardWidth = 223; // リサイズ後のカード幅
    const int cardHeight = 311; // リサイズ後のカード高さ
    const int padding = 10;
    const int headerHeight = 60; // デッキ名を描画するヘッダー領域の高さ

    final int rowCount = (imageBytesList.length / crossAxisCount).ceil();
    final int imageWidth = (cardWidth * crossAxisCount) + (padding * (crossAxisCount + 1));
    final int imageHeight = (cardHeight * rowCount) + (padding * (rowCount + 1)) + headerHeight;

    final deckImage = img.Image(width: imageWidth, height: imageHeight);
    img.fill(deckImage, color: img.ColorRgb8(255, 255, 255));

    // --- フォント読み込みと描画部分を変更 ---
    // try {
    //   // assetsからフォントファイルを読み込む
    //   final fontData = await rootBundle.load('assets/fonts/NotoSansJP-VariableFont_wght.ttf');
    //   // TTFフォントをデコード
    //   final font = img.TtfFont(fontData.buffer.asUint8List());
    //   final fonts = img.BitmapFont.fromFnt(fontData.buffer.asUint8List());
    //
    //   // デッキ名を中央に描画
    //   img.drawString(
    //     deckImage,
    //     deckName,
    //     font: font,
    //     x: padding,
    //     y: (headerHeight - 48) ~/ 2, // 縦方向中央揃え
     //     size: 48, // フォントサイズ
    //     color: img.ColorRgb8(0, 0, 0),
    //   );
    // } catch (e) {
    //   print("フォントの読み込みまたは描画に失敗しました: $e");
    //   // フォントがなくても処理を続ける（英数字で描画）
    //   img.drawString(deckImage, deckName, font: img.arial48, x: padding, y: padding);
    // }


    // カード画像を格子状に配置
    for (int i = 0; i < imageBytesList.length; i++) {
      final imageBytes = imageBytesList[i];
      final cardImage = img.decodeImage(imageBytes);
      if (cardImage == null) continue;

      // --- 画像リサイズ処理を追加 ---
      final resizedCard = img.copyResize(
        cardImage,
        width: cardWidth,
        height: cardHeight,
        interpolation: img.Interpolation.average, // 綺麗にリサイズするための補間方法
      );

      final int x = (i % crossAxisCount) * (cardWidth + padding) + padding;
      final int y = (i ~/ crossAxisCount) * (cardHeight + padding) + padding + headerHeight; // ヘッダー分のオフセット

      // リサイズした画像を合成
      img.compositeImage(deckImage, resizedCard, dstX: x, dstY: y);
    }
    return deckImage;
  }

  static Future<void> requestPermission() async {
    final status = await Permission.storage.request();
    if (status.isDenied) {
      await Permission.storage.request();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
