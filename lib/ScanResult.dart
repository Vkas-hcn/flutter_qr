import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'CreateDataPage.dart';
import 'mob/MobUtils.dart';
import 'mob/ScanUtils.dart';

class ScanResult extends StatefulWidget {
  final String scanResult;

  const ScanResult({super.key, required this.scanResult});

  @override
  State<ScanResult> createState() => _ScanResultState();
}

class _ScanResultState extends State<ScanResult> {
  bool qrLoading = false;
  late MobUtils adManager;

  @override
  void initState() {
    super.initState();
    adManager = ScanUtils.getMobUtils(context);
    adManager.loadAd(AdWhere.BACK);
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
        body: _buildScanResult(context, widget.scanResult),
      ),
    );
  }

  Widget _buildScanResult(BuildContext context, String scanResult) {
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
                    const Text("Result",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 18,
                          color: Colors.white,
                        )),
                  ],
                ),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 29),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF040A25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 140,
                          child: SingleChildScrollView(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                scanResult,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _copyText(scanResult);
                      },
                      child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.asset('assets/img/icon_copy.webp')),
                    ),
                    GestureDetector(
                      onTap: () {
                        launchSearchOrUrl(scanResult);
                      },
                      child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.asset('assets/img/icon_search.webp')),
                    ),
                  ],
                ),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 32),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF040A25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                    GestureDetector(
                      onTap: () {
                        backFun();
                      },
                      child: const SizedBox(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Continue scanning",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF040A25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                               const CreateDataPage()),
                        );
                      },
                      child: const SizedBox(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Generate QR code",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

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

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showToast('Copied to clipboard');
  }

  Future<void> launchSearchOrUrl(String input) async {
    final Uri url;
    if (Uri
        .tryParse(input)
        ?.hasAbsolutePath ?? false) {
      url = Uri.parse(input);
    } else {
      final query = Uri.encodeComponent(input);
      url = Uri.parse('https://www.google.com/search?q=$query');
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      final query = Uri.encodeComponent(input);
      await launchUrl(Uri.parse('https://www.google.com/search?q=$query'));
    }
  }
}
