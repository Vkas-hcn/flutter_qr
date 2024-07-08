

import 'mob_bean.dart';

class AdListBean {
  final int ss;
  final int qq;
  final List<AdBean> gfh;
  final List<AdBean> uui;
  final List<AdBean> rty;

  AdListBean(this.ss, this.qq, this.gfh, this.uui,
      this.rty);

  factory AdListBean.fromJson(Map<String, dynamic> json) {
    var adBackJson = json['gfh'] as List;
    var adTranslationJson = json['uui'] as List;
    var adOpenJson = json['rty'] as List;

    List<AdBean> adBackList = adBackJson.map((ad) => AdBean.fromJson(ad)).toList();
    List<AdBean> adTranslationList = adTranslationJson.map((ad) => AdBean.fromJson(ad)).toList();
    List<AdBean> adOpenList = adOpenJson.map((ad) => AdBean.fromJson(ad)).toList();

    return AdListBean(
      json['ss'] as int,
      json['qq'] as int,
      adBackList,
      adTranslationList,
      adOpenList,
    );
  }

  // toJson 方法
  Map<String, dynamic> toJson() {
    return {
      'ss': ss,
      'qq': qq,
      'gfh': gfh.map((ad) => ad.toJson()).toList(),
      'uui': uui.map((ad) => ad.toJson()).toList(),
      'rty': rty.map((ad) => ad.toJson()).toList(),
    };
  }
}