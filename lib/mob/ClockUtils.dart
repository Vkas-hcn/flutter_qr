import 'dart:convert';
import 'dart:io';
import 'package:advertising_id/advertising_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../SaveDataUtils.dart';


class ClockUtils with ChangeNotifier {
  static const String BLACK_URL =
      "https://madhya.swiftscannerpro.com/eclectic/italic/bode";
  static String fqaId = "";

  static String getUUID() {
    var uuid = Uuid();
    return uuid.v4(); // 生成一个唯一的UUID v4
  }

  static void initializeFqaId() {
    if (fqaId.isEmpty) {
      fqaId = getUUID();
    }
  }

  Future<void> getBlackList(BuildContext context) async {
    String? data = await SaveDataUtils.getString(SaveDataUtils.clockData);
    print("黑名单数据=${data}");

    if (data != null) {
      return;
    }
    final mapData = await cloakMapData(context);
    try {
      final response = await getMapData(BLACK_URL, mapData);
      SaveDataUtils.saveString(SaveDataUtils.clockData, response);
      notifyListeners();
    } catch (error) {
      retry(context);
    }
  }

  static void getAdvertisingId() async {
    String? advertisingId;
    try {
      advertisingId = await AdvertisingId.id(true);
    } on PlatformException {
      advertisingId = null;
    }
    await SaveDataUtils.saveString(
        SaveDataUtils.advertisingId, advertisingId ?? "");
  }

  Future<Map<String, dynamic>> cloakMapData(BuildContext context) async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    String? advertisingId;
    advertisingId = await SaveDataUtils.getString(SaveDataUtils.advertisingId);

    return {
      "exert": fqaId, // You need to replace fqa_id with actual value
      "roil": DateTime.now().millisecondsSinceEpoch,
      "edna": androidInfo.model,
      "typeset": "com.swiftscanner.pro",
      "crowd": androidInfo.version.release,
      "leander": "", // GAID is not directly available, you may need a plugin
      "dollop": androidInfo.id, // androidInfo.andro,
      "variant": "toll",
      "clammy": advertisingId,
      "bluebush": await getAppVersion(context),
    };
  }

  Future<String> getAppVersion(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<String> getMapData(String url, Map<String, dynamic> map) async {
    print("开始请求---${map}");
    final queryParameters = map.entries
        .map((entry) =>
    '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');

    final urlString =
    url.contains("?") ? "$url&$queryParameters" : "$url?$queryParameters";
    final response = await http.get(Uri.parse(urlString));

    if (response.statusCode == 200) {
      print("请求结果：${response.body}");
      return response.body;
    } else {
      print("请求出错：HTTP error: ${response.statusCode}");

      throw HttpException('HTTP error: ${response.statusCode}');
    }
  }

  void retry(BuildContext context) async {
    await Future.delayed(Duration(seconds: 10));
    await getBlackList(context);
  }
}
