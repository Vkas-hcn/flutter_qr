class AdBean {
  final String pp;
  final String ll;
  final String mm;
  final int kk;

  AdBean(this.pp, this.ll, this.mm, this.kk);


  // fromJson 方法
  factory AdBean.fromJson(Map<String, dynamic> json) {
    return AdBean(
      json['pp'] as String,
      json['ll'] as String,
      json['mm'] as String,
      json['kk'] as int,
    );
  }

  // toJson 方法
  Map<String, dynamic> toJson() {
    return {
      'pp': pp,
      'll': ll,
      'mm': mm,
      'kk': kk,
    };
  }
}