import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_qr/ScanResult.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:image_picker/image_picker.dart';

class QRViewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewPageState();
}

class _QRViewPageState extends State<QRViewPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool _isFlashOn = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool qrLoading = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation =
        Tween<double>(begin: 0, end: 200).animate(_animationController);
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        top: _animation.value,
                        child: Container(
                          width: 200,
                          height: 2,
                          color: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 100,
            left: 92,
            right: 92,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _pickImage();
                  },
                  child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.asset('assets/img/icon_picture.webp')),
                ),
                GestureDetector(
                  onTap: () {
                    _toggleFlash();
                  },
                  child: SizedBox(
                      width: 40,
                      height: 40,
                      child: _isFlashOn
                          ? Image.asset('assets/img/icon_flash_off.webp')
                          : Image.asset('assets/img/icon_flash.webp')),
                ),
              ],
            ),
          ),
          qrLoading
              ? Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: Colors.white,
                    size: 30,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      print("scannedDataStream===${_isProcessing}");
      if (!_isProcessing && scanData.code!.isNotEmpty) {
        setState(() {
          _isProcessing = true;
          result = scanData;
        });
        _navigateToResultPage(scanData.code!);
      }
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        result = Barcode(image.path, BarcodeFormat.unknown, []);
      });
      if (!_isProcessing && result!.code!.isNotEmpty) {
        setState(() {
          _isProcessing = true;
        });
        _navigateToResultPage(result!.code!);
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (controller != null) {
      await controller!.toggleFlash();
      bool? flashStatus = await controller!.getFlashStatus();
      setState(() {
        _isFlashOn = flashStatus ?? false;
      });
    }
  }

  Future<void> _navigateToResultPage(String scanResultData) async {
    await controller?.pauseCamera(); // Optional: pause the camera while navigating
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScanResult(scanResult: scanResultData),
      ),
    ).then((_) {
      setState(() {
        _isProcessing = false; // Reset the processing flag when coming back
      });
      controller?.resumeCamera(); // Optional: resume the camera when coming back
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller?.dispose();
    super.dispose();
  }
}
