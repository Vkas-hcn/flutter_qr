import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr/HomePage.dart';
import 'package:flutter_qr/SaveDataUtils.dart';
import 'package:flutter_qr/SaveDataUtils.dart';
import 'package:flutter_qr/SaveDataUtils.dart';
import 'package:flutter_qr/SaveDataUtils.dart';
import 'package:flutter_qr/SaveDataUtils.dart';
import 'package:flutter_qr/SaveDataUtils.dart';
import 'package:flutter_qr/SaveDataUtils.dart';
import 'package:flutter_qr/SaveDataUtils.dart';
import 'package:flutter_qr/mob/MobUtils.dart';
import 'package:flutter_qr/mob/QrLifeOb.dart';
import 'package:flutter_qr/mob/ScanUtils.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>{
  double _progress = 0.0;
  Timer? _timerProgress;
  Timer? _timerShowOPen;

  late QrLifeOb qrLifeOb;
  late MobUtils adManager;
  bool restartState = false;
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    _startProgress();
    adManager = ScanUtils.getMobUtils(context);
    qrLifeOb = QrLifeOb(
      onAppResumed: _handleAppResumed,
      onAppPaused: _handleAppPaused,
    );
    WidgetsBinding.instance.addObserver(qrLifeOb);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setADLoad();
    });
  }
  void setADLoad() async {
    await ScanUtils.getFileBaseData(() {
      print("initAdData callback");
      initAdData();
    });
  }
  void _startProgress() {
    const int totalDuration = 14000; // Total duration in milliseconds
    const int updateInterval = 50; // Update interval in milliseconds
    const int totalUpdates = totalDuration ~/ updateInterval;

    int currentUpdate = 0;

    _timerProgress = Timer.periodic(Duration(milliseconds: updateInterval), (timer) {
      setState(() {
        _progress = (currentUpdate + 1) / totalUpdates;
      });
      currentUpdate++;
      if (currentUpdate >= totalUpdates) {
        _timerProgress?.cancel();
      }
    });
  }
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(qrLifeOb);
  }
  void _handleAppResumed() {
    SaveDataUtils.isBackG = false;
    print("应用恢复前台");
    if (_pausedTime != null) {
      final timeInBackground =
          DateTime.now().difference(_pausedTime!).inSeconds;
      if (SaveDataUtils.clone_ad == true) {
        return;
      }
      if (SaveDataUtils.openImagePath == true) {
        SaveDataUtils.openImagePath = false;
        return;
      }
      print("应用恢复前台---${timeInBackground}===${SaveDataUtils.int_ad_show}");
      if (timeInBackground > 3 && SaveDataUtils.int_ad_show == false) {
        print("热启动");
        restartState = true;
        _restartApp();
      }
    }
  }

  void _restartApp() {
    restartApp(context);
  }

  void _handleAppPaused() {
    SaveDataUtils.isBackG = true;
    print("应用进入后台");
    SaveDataUtils.clone_ad = false;
    _pausedTime = DateTime.now();
  }

  void pageToHome() {
    print("pageToHome-----${restartState}");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
    restartState = false;
  }

  void initAdData() async {
    adManager.loadAd(AdWhere.OPEN);
    adManager.loadAd(AdWhere.SCAN);
    adManager.loadAd(AdWhere.BACK);
    Future.delayed(const Duration(seconds: 1), () {
      showOpenAd();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/bg_start.webp'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const SizedBox(height: 300),

                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Image.asset('assets/img/ic_start.webp'),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'APP Name',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 70,right: 40,left: 40),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProgressBar(
                        progress: _progress, // Set initial progress here
                        height: 8,
                        borderRadius: 16,
                        backgroundColor: Color(0x34FFFFFF),
                        progressColor: Color(0xFFFF00FF),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void restartApp(BuildContext context) {
    Navigator.of(context).removeRoute(ModalRoute.of(context) as Route);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const StartPage()),
            (route) => route == null);
  }
  void showOpenAd() {
    int elapsed = 0;
    const int timeout = 10000;
    const int interval = 500;
    print("准备展示open广告");
    _timerShowOPen = Timer.periodic(const Duration(milliseconds: interval), (timer) {
      elapsed += interval;
      if (SaveDataUtils.ad_more && !adManager.canShowAd(AdWhere.OPEN)) {
        print("广告超限，直接进入首页");
        pageToHome();
        timer.cancel();
        return;
      }
      if (adManager.canShowAd(AdWhere.OPEN)) {
        adManager.showAd(context, AdWhere.OPEN, () {
          pageToHome();
        });
        timer.cancel();
      } else if (elapsed >= timeout) {
        print("超时，直接进入首页");
        pageToHome();
        timer.cancel();
      }
    });
  }
}
class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color progressColor;

  ProgressBar({
    required this.progress,
    required this.height,
    required this.borderRadius,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}