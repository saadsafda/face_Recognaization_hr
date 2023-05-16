class EmployeeListItem {
  String? name;
  String? employeeName;

  EmployeeListItem({this.name, this.employeeName});

  EmployeeListItem.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    employeeName = json['employee_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['employee_name'] = this.employeeName;
    return data;
  }
}