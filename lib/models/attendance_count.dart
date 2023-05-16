class AttendanceCount {
  String? status;
  int? count;

  AttendanceCount({this.status, this.count});

  AttendanceCount.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    count = int.parse(json['count'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['count'] = this.count;
    return data;
  }
}
