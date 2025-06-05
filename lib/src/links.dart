import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LinksScreen extends StatelessWidget {
  const LinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const url1 = 'https://dm.takaratomy.co.jp/';
    const url2 = 'https://www.youtube.com/@-dm-1351';
    const url3 = 'https://x.com/t2duema';
    const url4 = 'https://www.dmp-ranking.com/';
    final urlLaunchWithStringButton = UrlLaunchWithStringButton();
    
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth =  MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('公式リンク'),
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: deviceWidth * 0.9 * 0.2,
                margin: EdgeInsets.fromLTRB(deviceWidth * 0.05,10,deviceWidth * 0.05, 10),
                child: ElevatedButton(
                    onPressed: (){urlLaunchWithStringButton.launchUriWithString(context, url1);},
                    style: ElevatedButton.styleFrom(
                        shape:RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        )
                    ),
                    child: const Text('デュエル・マスターズ 公式サイト！')
                ),
              ),
              Container(
                width: double.infinity,
                height: deviceWidth * 0.9 * 0.2,
                margin: EdgeInsets.fromLTRB(deviceWidth * 0.05,10,deviceWidth * 0.05, 10),
                child: ElevatedButton(
                    onPressed: (){urlLaunchWithStringButton.launchUriWithString(context, url2);},
                    style: ElevatedButton.styleFrom(
                        shape:RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        )
                    ),
                    child: const Text('デュエチューブ Youtube公式チャンネル！')
                ),
              ),
              Container(
                width: double.infinity,
                height: deviceWidth * 0.9 * 0.2,
                margin: EdgeInsets.fromLTRB(deviceWidth * 0.05,10,deviceWidth * 0.05, 10),
                child: ElevatedButton(
                    onPressed: (){urlLaunchWithStringButton.launchUriWithString(context, url3);},
                    style: ElevatedButton.styleFrom(
                        shape:RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        )
                    ),
                    child: const Text('デュエル・マスターズ Twitter公式アカウント！')
                ),
              ),
              Container(
                width: double.infinity,
                height: deviceWidth * 0.9 * 0.2,
                margin: EdgeInsets.fromLTRB(deviceWidth * 0.05,10,deviceWidth * 0.05, 10),
                  child: ElevatedButton(
                      onPressed: (){urlLaunchWithStringButton.launchUriWithString(context, url4);},
                      style: ElevatedButton.styleFrom(
                        shape:RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        )
                      ),
                      child: const Text('DMPランキング！')
                ),
              ),
            ],
          ),
        )

    );
  }
}

//webページ開く為のクラス
class UrlLaunchWithStringButton {
  final alertSnackBar = SnackBar(
    content: const Text('このURLは開けませんでした'),
    action: SnackBarAction(
      label: '戻る',
      onPressed: () {},
    ),
  );

  Future launchUriWithString(BuildContext context, String url) async {
    try {
      var launched = await launchUrlString(url);
      if(!launched) {
        await launchUrlString(url);
      }
    } catch (e) {
      alertSnackBar;
      ScaffoldMessenger.of(context).showSnackBar(alertSnackBar);
    }
  }
}

