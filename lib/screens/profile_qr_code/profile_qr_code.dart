import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:listar/configs/config.dart';
import 'package:listar/models/model.dart';
import 'package:listar/utils/utils.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileQRCode extends StatefulWidget {
  final UserModel user;

  const ProfileQRCode({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _ProfileQRCodeState createState() {
    return _ProfileQRCodeState();
  }
}

class _ProfileQRCodeState extends State<ProfileQRCode>
    with SingleTickerProviderStateMixin {
  final qrKey = GlobalKey(debugLabel: 'QR');

  int _indexTab = 0;
  TabController? _tabController;
  QRViewController? _qrController;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _qrController?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    _qrController?.pauseCamera();
    _qrController?.resumeCamera();
  }

  ///Flow Scan Code
  void _onQRViewCreated(controller) {
    _qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_done) {
        try {
          final user = UserModel.fromJson(jsonDecode(scanData.code));
          Navigator.pop(context, user);
        } catch (e) {
          UtilLogger.log("ERROR", e);
        }
      }
      _done = true;
    });
  }

  ///On Change Tab
  void _onTap(int index) {
    setState(() {
      _indexTab = index;
    });
    if (_indexTab == 0) {
      _qrController?.pauseCamera();
      _qrController?.resumeCamera();
    }
  }

  ///Build Content
  Widget _buildContent() {
    ///QR code build
    if (_indexTab == 0) {
      final userData = widget.user.toJson();
      userData.remove('token');
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: 30,
                      left: 16,
                      right: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).focusColor,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(widget.user.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.user.name,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                    Container(
                      width: 160,
                      height: 160,
                      margin: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      child: QrImage(
                        data: jsonEncode(userData),
                        size: 160,
                        backgroundColor: Colors.white,
                        errorStateBuilder: (cxt, err) {
                          return const Text(
                            "Uh oh! Something went wrong...",
                            textAlign: TextAlign.center,
                          );
                        },
                        embeddedImage: const AssetImage(Images.logo),
                        embeddedImageStyle: QrEmbeddedImageStyle(
                          size: const Size(32, 32),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      );
    }

    ///Scan QR code
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).primaryColor,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Translate.of(context).translate('profile_qrcode')),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                indicatorWeight: 3.0,
                controller: _tabController,
                tabs: [
                  Tab(text: Translate.of(context).translate('my_qrcode')),
                  Tab(text: Translate.of(context).translate('scan_qrcode')),
                ],
                onTap: _onTap,
                labelColor: Theme.of(context).textTheme.button?.color,
              ),
            ),
            Expanded(
              child: _buildContent(),
            )
          ],
        ),
      ),
    );
  }
}
