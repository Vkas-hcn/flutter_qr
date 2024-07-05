

import 'mob_bean.dart';

class AdListBean {
  final int click_num;
  final int show_num;
  final List<AdBean> ad_back;
  final List<AdBean> ad_scan;
  final List<AdBean> ad_open;

  AdListBean(this.click_num, this.show_num, this.ad_back, this.ad_scan,
      this.ad_open);

  factory AdListBean.fromJson(Map<String, dynamic> json) {
    var adBackJson = json['ad_back'] as List;
    var adTranslationJson = json['ad_scan'] as List;
    var adOpenJson = json['ad_open'] as List;

    List<AdBean> adBackList = adBackJson.map((ad) => AdBean.fromJson(ad)).toList();
    List<AdBean> adTranslationList = adTranslationJson.map((ad) => AdBean.fromJson(ad)).toList();
    List<AdBean> adOpenList = adOpenJson.map((ad) => AdBean.fromJson(ad)).toList();

    return AdListBean(
      json['click_num'] as int,
      json['show_num'] as int,
      adBackList,
      adTranslationList,
      adOpenList,
    );
  }

  // toJson 方法
  Map<String, dynamic> toJson() {
    return {
      'click_num': click_num,
      'show_num': show_num,
      'ad_back': ad_back.map((ad) => ad.toJson()).toList(),
      'ad_scan': ad_scan.map((ad) => ad.toJson()).toList(),
      'ad_open': ad_open.map((ad) => ad.toJson()).toList(),
    };
  }
}