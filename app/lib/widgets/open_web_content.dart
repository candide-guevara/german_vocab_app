import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

VoidCallback buildOpenWebViewCb(BuildContext context, title, url) {
  return () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(title: title, url: url,),),
    );
}

VoidCallback buildCallDeepLCb(BuildContext context, word) {
  final url = Uri.encodeFull("https://www.deepl.com/en/translator#de/en/${word}");
  return () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(title: word, url: url,),),
    );
}

class WebViewScreen extends StatelessWidget {
  final String title;
  final String url;

  WebViewScreen({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      //..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(NavigationDelegate(
          //onProgress: (int progress) {},
          //onPageStarted: (String url) {},
          //onPageFinished: (String url) {},
          //onHttpError: (HttpResponseError error) {},
          //onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (_) => NavigationDecision.prevent,
        ))
      ..loadRequest(Uri.parse(url));
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ColorFiltered(
        colorFilter: ColorFilter.matrix(
          <double>[
            -1,  0,  0,  0, 255, // Red
             0, -1,  0,  0, 255, // Green
             0,  0, -1,  0, 255, // Blue
             0,  0,  0,  1,   0, // Alpha
          ],
        ),
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}

