import 'dart:ffi';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class SaveDataUtils {
  static List<String> imagePaths = [
    'assets/img/img_qr_bg_0.webp',
    'assets/img/img_qr_bg_1.webp',
    'assets/img/img_qr_bg_2.webp',
    'assets/img/img_qr_bg_3.webp',
    'assets/img/img_qr_bg_4.webp',
    'assets/img/img_qr_bg_5.webp',
    'assets/img/img_qr_bg_6.webp',
    'assets/img/img_qr_bg_7.webp',
    'assets/img/img_qr_bg_8.webp',
    'assets/img/img_qr_bg_9.webp',
    'assets/img/img_qr_bg_10.webp',
    'assets/img/img_qr_bg_11.webp',
    'assets/img/img_qr_bg_12.webp',
    'assets/img/img_qr_bg_13.webp',
    'assets/img/img_qr_bg_14.webp',
  ];
  static List<Color> qrColors = [
    const Color(0xFF000000),
    const Color(0xFFFFFFFF),
    const Color(0xFFCCCCCC),
    const Color(0xFF51C7FC),
    const Color(0xFFEF3797),
    const Color(0xFF36DC5E),
    const Color(0xFFFF8644),
    const Color(0xFFF4BF42),
    const Color(0xFFF4668F),
  ];

  static String adDataKey = 'servant';
  static String clockDataKey = 'sheet';

  static String adData = 'adData';

  static String clockData = 'clockData';
  static String last_reset = "last_reset";
  static String ad_click_counts = "ad_click_counts";
  static String ad_show_counts = "ad_show_counts";
  static bool ad_more = false;
  static bool int_ad_show = false;
  static bool clone_ad = false;
  static bool openImagePath = false;
  static String advertisingId = "advertisingId";
  static const String appOpenAdKey = "appOpenAdKey";
  static bool isBackG = false;

  static String sheet = "sheet";

  static String createState = "createState";
  static String createQrBg = "createQrBg";


  static String createTextData = "createTextData";

  static String createNetData = "createNetData";
  static String createNetPass = "createNetPass";

  static String createCountry = "createCountry";
  static String createCity = "createCity";
  static String createLongitude = "createLongitude";
  static String createLatitude = "createLatitude";

  static String createEmail = "createEmail";
  static String createContent = "createContent";

  static String createUrl = "createUrl";

  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }
  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<void> saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  static Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  static Future<void> saveStringList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  static Future<List<String>?> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> saveAppOpenAdId(String adId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(appOpenAdKey, adId);
  }

  static Future<String?> getAppOpenAdId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(appOpenAdKey);
  }
}
