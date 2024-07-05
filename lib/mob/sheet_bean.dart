class SheetBean {
  final String structure;

  SheetBean(this.structure);

  factory SheetBean.fromJson(Map<String, dynamic> json) {
    return SheetBean(
      json['structure'] as String,
    );
  }

  // toJson 方法
  Map<String, dynamic> toJson() {
    return {
      'structure': structure,
    };
  }
}