class TodayCheckinModel {
  String? name;
  String? log_type;
  String? time;

  TodayCheckinModel({
    this.name,
    this.log_type,
    this.time,
  });

  // fromJson
  TodayCheckinModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    log_type = json['log_type'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['log_type'] = this.log_type;
    data['time'] = this.time;
    return data;
  }
}
