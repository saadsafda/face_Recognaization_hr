class EmployeeAttendance {
  String? name;
  String? employee;
  String? employeeName;
  double? workingHours;
  String? status;
  String? attendanceDate;
  String? inTime;
  String? outTime;
  int? lateEntry;
  int? earlyExit;

  EmployeeAttendance(
      {this.name,
      this.employee,
      this.employeeName,
      this.workingHours,
      this.status,
      this.attendanceDate,
      this.inTime,
      this.outTime,
      this.lateEntry,
      this.earlyExit});

  EmployeeAttendance.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    employee = json['employee'];
    employeeName = json['employee_name'];
    workingHours = json['working_hours'];
    status = json['status'];
    attendanceDate = json['attendance_date'];
    inTime = json['in_time'];
    outTime = json['out_time'];
    lateEntry = json['late_entry'];
    earlyExit = json['early_exit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['employee'] = this.employee;
    data['employee_name'] = this.employeeName;
    data['working_hours'] = this.workingHours;
    data['status'] = this.status;
    data['attendance_date'] = this.attendanceDate;
    data['in_time'] = this.inTime;
    data['out_time'] = this.outTime;
    data['late_entry'] = this.lateEntry;
    data['early_exit'] = this.earlyExit;
    return data;
  }
}
