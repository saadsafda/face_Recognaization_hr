class GpsLocationModel {
  String? name;
  String? location_name;
  String? location_gps;
  double? allowed_radius;

  GpsLocationModel({
    this.name,
    this.location_name,
    this.location_gps,
    this.allowed_radius,
  });

  // fromJson
  GpsLocationModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    location_name = json['location_name'];
    location_gps = json['location_gps'];
    allowed_radius = json['allowed_radius'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['location_name'] = this.location_name;
    data['location_gps'] = this.location_gps;
    data['allowed_radius'] = this.allowed_radius;
    return data;
  }
}
