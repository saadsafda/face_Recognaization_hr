class Checkin {
  String? name;
  String? employeeName;
  String? logType;
  String? time;

  Checkin({this.name, this.employeeName, this.logType, this.time});

  Checkin.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    employeeName = json['employee_name'];
    logType = json['log_type'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['employee_name'] = this.employeeName;
    data['log_type'] = this.logType;
    data['time'] = this.time;
    return data;
  }
}
