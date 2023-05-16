class Employee {
  String? name;
  String? firstName;
  String? middleName;
  String? lastName;
  String? salutation;
  String? employeeName;
  String? image;
  String? employeeFaceId;
  String? gender;
  String? dateOfBirth;
  String? dateOfJoining;
  String? userId;
  String? dateOfRetirement;
  String? department;
  String? designation;
  String? preferedEmail;
  String? companyEmail;

  Employee(
      {this.name,
      this.firstName,
      this.middleName,
      this.lastName,
      this.salutation,
      this.employeeName,
      this.image,
      this.employeeFaceId,
      this.gender,
      this.dateOfBirth,
      this.dateOfJoining,
      this.userId,
      this.dateOfRetirement,
      this.department,
      this.designation,
      this.preferedEmail,
      this.companyEmail});

  Employee.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    firstName = json['first_name'];
    middleName = json['middle_name'];
    lastName = json['last_name'];
    salutation = json['salutation'];
    employeeName = json['employee_name'];
    image = json['image'];
    employeeFaceId = json['employee_face_id'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
    dateOfJoining = json['date_of_joining'];
    userId = json['user_id'];
    dateOfRetirement = json['date_of_retirement'];
    department = json['department'];
    designation = json['designation'];
    preferedEmail = json['prefered_email'];
    companyEmail = json['company_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['first_name'] = this.firstName;
    data['middle_name'] = this.middleName;
    data['last_name'] = this.lastName;
    data['salutation'] = this.salutation;
    data['employee_name'] = this.employeeName;
    data['image'] = this.image;
    data['employee_face_id'] = this.employeeFaceId;
    data['gender'] = this.gender;
    data['date_of_birth'] = this.dateOfBirth;
    data['date_of_joining'] = this.dateOfJoining;
    data['user_id'] = this.userId;
    data['department'] = this.department;
    data['designation'] = this.designation;
    data['date_of_retirement'] = this.dateOfRetirement;
    data['prefered_email'] = this.preferedEmail;
    data['company_email'] = this.companyEmail;
    return data;
  }
}
