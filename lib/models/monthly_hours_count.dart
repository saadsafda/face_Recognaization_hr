class MonthlyHoursCount {
  String? status;
  double? count;
  bool? isOk;

  MonthlyHoursCount({this.status, this.count, this.isOk});

  MonthlyHoursCount.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    count = double.parse(json['count'].toString());
    isOk = json['isOk'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['count'] = this.count;
    data['isOk'] = this.isOk;
    return data;
  }
}
