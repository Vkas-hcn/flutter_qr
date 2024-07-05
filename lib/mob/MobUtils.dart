import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../SaveDataUtils.dart';
import 'ScanUtils.dart';
import 'ad_list_bean.dart';
import 'mob_bean.dart';


enum AdWhere {
  OPEN,
  SCAN,
  BACK,
}

class MobUtils {
  static final MobUtils _instance = MobUtils._internal();

  factory MobUtils() {
    return _instance;
  }

  MobUtils._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoading = false;
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdLoading = false;
  int _currentAdIndex = 0;
  bool isFistOpen = false;
  int adLoadTimes = 0;

  void loadAd(AdWhere adPosition) async {
    _resetCountsIfNeeded();
    if (_isAppOpenAdLoading || _isInterstitialAdLoading) {
      print("$adPosition广告加载中");
      return;
    }
    if (canMoreAd(adPosition)) {
      print("广告缓存已过期");
      clearAdCache();
    }
    if (canShowAd(adPosition)) {
      print("已有$adPosition广告缓存,不再加载");
      return;
    }
    bool colckState = await ScanUtils.blacklistBlocking();
    if (adPosition != AdWhere.OPEN && colckState) {
      print("$adPosition广告黑名单屏蔽");
      return;
    }
    AdListBean adList = await ScanUtils.getAdList();
    var canLoad = await _canLoadAd(adList);
    if (!canLoad) {
      SaveDataUtils.ad_more = true;
      print("广告超限");
      return;
    }
    SaveDataUtils.ad_more = false;
    switch (adPosition) {
      case AdWhere.OPEN:
        _loadAppOpenAd(adList.ad_open);
        break;
      case AdWhere.SCAN:
      case AdWhere.BACK:
        _loadInterstitialAd(
            adPosition == AdWhere.SCAN
                ? adList.ad_scan
                : adList.ad_back,
            adPosition);
        break;
    }
  }

  List<AdBean> sortAdsByWe(List<AdBean> ads) {
    ads.sort((a, b) => b.ad_we.compareTo(a.ad_we));
    return List<AdBean>.from(ads);
  }

  void _loadAppOpenAd(List<AdBean> adListBean) {
    var sortedAds = sortAdsByWe(adListBean);
    _loadAppOpenAdWithRetry(sortedAds, _currentAdIndex);
  }

  void _loadAppOpenAdWithRetry(List<AdBean> adListBean, int index) {
    if (index >= adListBean.length) {
      if (!isFistOpen) {
        isFistOpen = true;
        _currentAdIndex = 0;
        _loadAppOpenAd(adListBean);
      }
      return;
    }
    _isAppOpenAdLoading = true;
    AdBean adBean = adListBean[index];
    print("加载open广告 ad_id=${adBean.ad_id}，ad_we=${adBean.ad_we}");
    AppOpenAd.load(
      adUnitId: adBean.ad_id,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print("open广告加载成功");
          adLoadTimes = DateTime.now().millisecondsSinceEpoch;
          _appOpenAd = ad;
          _isAppOpenAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          print('open广告加载失败: $error');
          _isAppOpenAdLoading = false;
          _appOpenAd = null;
          _loadAppOpenAdWithRetry(adListBean, index + 1);
        },
      ),
      orientation: AppOpenAd.orientationPortrait,
    );
  }

  void _loadInterstitialAd(List<AdBean> adListBean, AdWhere adPosition) {
    var sortedAds = sortAdsByWe(adListBean);
    _loadInterstitialAdWithRetry(sortedAds, _currentAdIndex, adPosition);
  }

  void _loadInterstitialAdWithRetry(
      List<AdBean> adListBean, int index, AdWhere adPosition) {
    if (index >= adListBean.length) return;
    _isInterstitialAdLoading = true;
    AdBean adBean = adListBean[index];
    print("加载$adPosition广告 ad_id=${adBean.ad_id}，ad_we=${adBean.ad_we}");
    InterstitialAd.load(
      adUnitId: adBean.ad_id,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print("加载${adPosition}广告加载成功");
          adLoadTimes = DateTime.now().millisecondsSinceEpoch;
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          print("加载${adPosition}广告加载失败：${error}");
          _isInterstitialAdLoading = false;
          _appOpenAd = null;
          _loadInterstitialAdWithRetry(adListBean, index + 1, adPosition);
        },
      ),
    );
  }

  bool canMoreAd(AdWhere adWhere) {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (adWhere == AdWhere.OPEN) {
      return _appOpenAd != null && now - adLoadTimes > 3 * 60 * 60 * 1000;
    } else {
      return _interstitialAd != null && now - adLoadTimes > 50 * 60 * 1000;
    }
  }

  //清除广告缓存
  void clearAdCache() {
    _appOpenAd = null;
    _interstitialAd = null;
    _isInterstitialAdLoading = false;
    _isAppOpenAdLoading = false;
  }

  void showAd(
      BuildContext context, AdWhere adPosition, Function() cloneWindow) async {
    if (SaveDataUtils.isBackG) {
      print("后台不展示广告");
      return;
    }
    adCall(adPosition, cloneWindow);
    if (adPosition == AdWhere.OPEN && _appOpenAd != null) {
      _appOpenAd!.show();
    } else if ((adPosition == AdWhere.SCAN ||
        adPosition == AdWhere.BACK) &&
        _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print('No ad available to show');
    }
  }

  bool canShowAd(AdWhere adWhere) {
    switch (adWhere) {
      case AdWhere.OPEN:
        return _appOpenAd != null;
      case AdWhere.SCAN:
      case AdWhere.BACK:
        return _interstitialAd != null;
    }
  }

  void closeAppOpenAd() {
    if (_appOpenAd != null) {
      print("主动关闭广告");
      _appOpenAd!.fullScreenContentCallback!
          .onAdDismissedFullScreenContent!(_appOpenAd!);
    }
  }

  void adCall(AdWhere adPosition, Function() cloneWindow) {
    if (_appOpenAd != null) {
      _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (AppOpenAd ad) {
          print("关闭open广告");
          SaveDataUtils.int_ad_show = false;
          SaveDataUtils.clone_ad = true;
          cloneWindow();
          ad.dispose();
        },
        onAdWillDismissFullScreenContent: (AppOpenAd ad) {
          print("即将关闭open广告");
        },
        onAdShowedFullScreenContent: (AppOpenAd ad) {
          SaveDataUtils.int_ad_show = true;
          _appOpenAd = null;
          print("展示open广告");
          _incrementAdShowCount();
        },
        onAdClicked: (AppOpenAd ad) {
          print("点击open广告");
          _incrementAdClickCount();
          ad.dispose();
        },
      );
    }
    if (_interstitialAd != null) {
      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print("关闭$adPosition插屏广告");
          SaveDataUtils.int_ad_show = false;
          SaveDataUtils.clone_ad = true;
          ad.dispose();
          loadAd(adPosition);
          cloneWindow();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
        },
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          _interstitialAd = null;
          SaveDataUtils.int_ad_show = true;
          print("展示$adPosition插屏广告");
          _incrementAdShowCount();
        },
        onAdClicked: (InterstitialAd ad) {
          print("点击$adPosition广告");
          _incrementAdClickCount();
          ad.dispose();
        },
      );
    }
  }

  void _resetCountsIfNeeded() async {
    final now = DateTime.now();
    var lastResetData = await SaveDataUtils.getInt(SaveDataUtils.last_reset);
    final lastReset = DateTime.fromMillisecondsSinceEpoch(lastResetData ?? 0);
    if (now.difference(lastReset).inDays >= 1) {
      SaveDataUtils.saveInt(SaveDataUtils.last_reset, now.millisecondsSinceEpoch);
      SaveDataUtils.saveInt(SaveDataUtils.ad_click_counts, 0);
      SaveDataUtils.saveInt(SaveDataUtils.ad_show_counts, 0);
    }
  }

  Future<void> _incrementAdClickCount() async {
    var clickCounts =
        await SaveDataUtils.getInt(SaveDataUtils.ad_click_counts) ?? 0;
    clickCounts = clickCounts + 1;
    SaveDataUtils.saveInt(SaveDataUtils.ad_click_counts, clickCounts);
  }

  Future<void> _incrementAdShowCount() async {
    var showCounts =
        await SaveDataUtils.getInt(SaveDataUtils.ad_show_counts) ?? 0;
    showCounts = showCounts + 1;
    SaveDataUtils.saveInt(SaveDataUtils.ad_show_counts, showCounts);
  }

  Future<bool> _canLoadAd(AdListBean adBean) async {
    var clickNum = await SaveDataUtils.getInt(SaveDataUtils.ad_click_counts) ?? 0;
    var showNum = await SaveDataUtils.getInt(SaveDataUtils.ad_show_counts) ?? 0;
    print("clickNum=$clickNum, showNum=$showNum");
    print(
        "adBean.click_num=${adBean.click_num}, adBean.show_num=${adBean.show_num}");

    return (clickNum < adBean.click_num) && (showNum < adBean.show_num);
  }
}
