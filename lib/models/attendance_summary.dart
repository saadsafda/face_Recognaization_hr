class AttendanceSummary {
  int? presents;
  int? absents;
  int? lates;
  int? early;

  AttendanceSummary({
    this.presents,
    this.absents,
    this.lates,
    this.early,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) =>
      AttendanceSummary(
        presents: json["presents"] ?? 0,
        absents: json["absents"] ?? 0,
        lates: json["lates"] ?? 0,
        early: json["early"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "presents": presents ?? 0,
        "absents": absents ?? 0,
        "lates": lates ?? 0,
        "early": early ?? 0,
      };
}
