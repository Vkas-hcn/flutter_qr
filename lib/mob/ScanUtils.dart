import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr/mob/sheet_bean.dart';
import 'package:provider/provider.dart';

import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../SaveDataUtils.dart';
import 'MobUtils.dart';
import 'ad_list_bean.dart';

class ScanUtils {
  static MobUtils getMobUtils(BuildContext context) {
    final adManager = Provider.of<MobUtils>(context, listen: false);
    return adManager;
  }

  static Future<AdListBean> getAdList() async {
    var fileBaseAdData = await SaveDataUtils.getString(SaveDataUtils.adDataKey);
    if (fileBaseAdData != null && fileBaseAdData.isNotEmpty) {
      Map<String, dynamic> jsonData = json.decode(fileBaseAdData);
      AdListBean adListBean = AdListBean.fromJson(jsonData);
      return adListBean;
    }
    String jsonString = await rootBundle.loadString('assets/json/ad_data.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);
    AdListBean adListBean = AdListBean.fromJson(jsonData);
    return adListBean;
  }

  static Future<SheetBean> getSheetData() async {
    var fileBaseAdData =
        await SaveDataUtils.getString(SaveDataUtils.clockDataKey);
    if (fileBaseAdData != null && fileBaseAdData.isNotEmpty) {
      Map<String, dynamic> jsonData = json.decode(fileBaseAdData);
      SheetBean adListBean = SheetBean.fromJson(jsonData);
      return adListBean;
    }
    String jsonString = await rootBundle.loadString('assets/json/sheet.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);
    SheetBean adListBean = SheetBean.fromJson(jsonData);
    return adListBean;
  }

  //黑名单屏蔽
  static Future<bool> blacklistBlocking() async {
    String data = (await getSheetData()).structure;
    if (data == "1" &&
        SaveDataUtils.getString(SaveDataUtils.clockData) != "coeditor") {
      return true;
    }
    if (data == "2") {
      return false;
    }
    return true;
  }

  static Future<void> getFileBaseData(Function() nextFun) async {
    bool isCa = false;
    try {
      print("getFileBaseData");
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
      remoteConfig.setDefaults(<String, dynamic>{
        SaveDataUtils.adDataKey: '',
        SaveDataUtils.clockDataKey: '',
      });
      // Fetch and activate remote config values
      remoteConfig.fetchAndActivate().then((_) {
        var adData = remoteConfig.getString(SaveDataUtils.adDataKey);
        SaveDataUtils.saveString(SaveDataUtils.iwer, adData);
        var clockData = remoteConfig.getString(SaveDataUtils.clockDataKey);
        SaveDataUtils.saveString(SaveDataUtils.hap66, clockData);
        isCa = true;
      });

      await Future.any([
        Future.delayed(const Duration(seconds: 4)),
        Future.doWhile(() async {
          if (isCa) {
            nextFun();
            return false;
          }
          await Future.delayed(const Duration(milliseconds: 500));
          return true;
        }),
      ]);
    } catch (e) {
      print('Failed to fetch remote config: $e');
    }
    if (!isCa) {
      print("FileBaseData获取超时");
      nextFun();
    }
  }

  static Future<void> showScanAd(
    BuildContext context,
    AdWhere adPosition,
    Function() loadingFun,
    Function() nextFun,
  ) async {
    final Completer<void> completer = Completer<void>();
    var isCancelled = false;

    void cancel() {
      isCancelled = true;
      completer.complete();
    }

    Future<void> _checkAndShowAd() async {
      if (SaveDataUtils.ad_more &&
          !ScanUtils.getMobUtils(context).canShowAd(adPosition)) {
        nextFun();
        return;
      }

      bool colckState = await ScanUtils.blacklistBlocking();
      if (colckState) {
        nextFun();
        return;
      }

      if (ScanUtils.getMobUtils(context).canShowAd(adPosition)) {
        loadingFun();
        ScanUtils.getMobUtils(context).showAd(context, adPosition, nextFun);
        return;
      }
      if (!isCancelled) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _checkAndShowAd(); 
      }
    }
    Future.delayed(const Duration(seconds: 4), cancel);
    await Future.any([
      _checkAndShowAd(),
      completer.future, 
    ]);

    if (!completer.isCompleted) {
      return;
    }
    print("插屏广告展示超时");
    nextFun();
  }
}
