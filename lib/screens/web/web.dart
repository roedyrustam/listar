import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
import 'package:listar/models/model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Web extends StatefulWidget {
  final WebViewModel web;
  const Web({Key? key, required this.web}) : super(key: key);

  @override
  _WebState createState() {
    return _WebState();
  }
}

class _WebState extends State<Web> {
  final _cookieManager = CookieManager();

  bool _loadCompleted = false;
  bool _receiveCallback = false;
  String? _callbackResult;
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
    SVProgressHUD.show();
  }

  @override
  void dispose() {
    SVProgressHUD.dismiss();
    super.dispose();
  }

  void _onResult() {
    Navigator.pop(context, _callbackResult);
  }

  ///Clear Cookie
  Future<void> _clearCookie() async {
    SVProgressHUD.dismiss();
    if (Platform.isIOS) {
      await _controller?.clearCache();
    } else {
      await _cookieManager.clearCookies();
    }
  }

  ///After load page finish
  void onPageFinished(BuildContext context, String url) async {
    SVProgressHUD.dismiss();
    if (!_loadCompleted) {
      setState(() {
        _loadCompleted = true;
      });
    }

    ///Handle callback
    if (_callbackResult != null && !_receiveCallback) {
      await _clearCookie();
      _receiveCallback = true;
      _onResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.web.title,
        ),
      ),
      body: IndexedStack(
        index: _loadCompleted ? 1 : 0,
        children: [
          Container(
            color: Theme.of(context).backgroundColor,
          ),
          WebView(
            initialUrl: widget.web.url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (webViewController) {
              _controller = webViewController;
            },
            onPageStarted: (String url) {
              SVProgressHUD.show();
            },
            onPageFinished: (String url) {
              onPageFinished(context, url);
            },
            navigationDelegate: (request) {
              for (var item in widget.web.callbackUrl) {
                if (request.url.contains(item)) {
                  _callbackResult = item;
                  break;
                }
              }
              return NavigationDecision.navigate;
            },
            gestureNavigationEnabled: true,
          ),
        ],
      ),
    );
  }
}
