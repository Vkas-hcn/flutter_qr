class AdBean {
  final String ad_id;
  final String ad_type;
  final String ad_where;
  final int ad_we;

  AdBean(this.ad_id, this.ad_type, this.ad_where, this.ad_we);


  // fromJson 方法
  factory AdBean.fromJson(Map<String, dynamic> json) {
    return AdBean(
      json['ad_id'] as String,
      json['ad_type'] as String,
      json['ad_where'] as String,
      json['ad_we'] as int,
    );
  }

  // toJson 方法
  Map<String, dynamic> toJson() {
    return {
      'ad_id': ad_id,
      'ad_type': ad_type,
      'ad_where': ad_where,
      'ad_we': ad_we,
    };
  }
}