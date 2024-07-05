import 'dart:io';
import 'dart:ui';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr/SaveDataUtils.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'HomePage.dart';
import 'mob/MobUtils.dart';
import 'mob/ScanUtils.dart';

class CreateStylePage extends StatefulWidget {
  final String qrData;

  const CreateStylePage({super.key, required this.qrData});

  @override
  State<CreateStylePage> createState() => _CreateStylePageState();
}

class _CreateStylePageState extends State<CreateStylePage> {
  int qrStyle = 0;
  int qrColor = 0;
  bool isLoading = true;
  bool qrLoading = false;

  String qrDataType = "Text";
  final GlobalKey _globalKey = GlobalKey();
  late MobUtils adManager;

  Future<void> _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/image.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      await ImageGallerySaver.saveImage(pngBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully saved to album')),
      );
    } catch (e) {
      print(e);
    }
  }
  @override
  void initState() {
    super.initState();
    getQrDataType();
    seCState();
    adManager = ScanUtils.getMobUtils(context);
    adManager.loadAd(AdWhere.BACK);
  }

  Future<void> getQrDataType() async {
    qrDataType = (await SaveDataUtils.getString(SaveDataUtils.createState))!;
    setState(() {
      isLoading = false;
    });
  }
  void seCState() async {
    qrStyle = (await SaveDataUtils.getInt(SaveDataUtils.createQrBg))!;
  }
  @override
  void dispose() {
    super.dispose();
  }

  void backFun() async {
    if (!adManager.canShowAd(AdWhere.BACK)) {
      adManager.loadAd(AdWhere.BACK);
    }
    setState(() {
      qrLoading = true;
    });
    ScanUtils.showScanAd(context, AdWhere.BACK, () {
      setState(() {
        qrLoading = false;
      });
    }, () {
      setState(() {
        qrLoading = false;
      });
      Navigator.pop(context);
    });
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        backFun();
      },
      child: Scaffold(
        body: isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : _buildCreateStylePage(context, widget.qrData),
      ),
    );
  }

  Widget _buildCreateStylePage(BuildContext context, String qrData) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/bg_main.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(top: 56),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        backFun();
                      },
                    ),
                    const Text("Create",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 18,
                          color: Colors.white,
                        )),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: GradientButton(
                        padding: 8,
                        colors: const [
                          Color(0xFF35D4FF),
                          Color(0xFFFF00FF),
                          Color(0xFFFFFF86)
                        ],
                        borderRadius: BorderRadius.circular(8),
                        onPressed: () {
                          _capturePng();
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 14,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0,left: 20,right: 20),
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: Container(
                      width: qrDataType == "Barcode"?double.maxFinite:184,
                      height: 184,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(qrDataType == "Barcode"?SaveDataUtils.imagePaths[0]:SaveDataUtils.imagePaths[qrStyle]),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: qrDataType == "Barcode"?BarcodeWidget(
                            barcode: Barcode.code128(),
                            data: qrData,
                          ):QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: SaveDataUtils.qrColors[qrColor],
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: SaveDataUtils.qrColors[qrColor],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if(qrDataType != "Barcode")
                const Padding(
                  padding: EdgeInsets.only(top: 32, left: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Background",
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
                if(qrDataType != "Barcode")
                  Padding(
                  padding:
                      const EdgeInsets.only(top: 24.0, left: 20, right: 20),
                  child: SizedBox(
                    height: 88,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: SaveDataUtils.imagePaths.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            SaveDataUtils.saveInt(
                                SaveDataUtils.createQrBg, index);
                            setState(() {
                              qrStyle = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage(SaveDataUtils.imagePaths[index]),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child:
                                Stack(alignment: Alignment.topRight, children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: SizedBox(
                                    width: 58,
                                    height: 58,
                                    child: Image.asset(
                                        'assets/img/ic_qr_code_2.webp'),
                                  ),
                                ),
                              ),
                              if (qrStyle == index)
                                SizedBox(
                                  width: 29,
                                  height: 29,
                                  child:
                                      Image.asset('assets/img/icon_sel.webp'),
                                )
                            ]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if(qrDataType != "Barcode")
                  const Padding(
                  padding: EdgeInsets.only(top: 32, left: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Color",
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
                if(qrDataType != "Barcode")
                  Padding(
                  padding:
                      const EdgeInsets.only(top: 24.0, left: 20, right: 20),
                  child: SizedBox(
                    height: 52,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: SaveDataUtils.qrColors.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            SaveDataUtils.saveInt(
                                SaveDataUtils.createQrBg, index);
                            setState(() {
                              qrColor = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 15.0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                  child: CustomCircle(
                                      color: SaveDataUtils.qrColors[index]),
                                ),
                                if (qrColor == index)
                                  SizedBox(
                                    width: 29,
                                    height: 29,
                                    child:
                                        Image.asset('assets/img/icon_sel.webp'),
                                  )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                qrLoading
                    ? Center(
                  child: Container(

                    decoration: BoxDecoration(
                      color: const Color(0xFF252325),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                      child: LoadingAnimationWidget.waveDots(
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                )
                    : Container(),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

class CustomCircle extends StatelessWidget {
  final Color color;

  const CustomCircle({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
