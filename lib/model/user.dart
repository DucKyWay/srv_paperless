import 'package:srv_paperless/services/password_services.dart';

enum AcademicDepartment {
  science(label:'วิทยาศาสตร์และเทคโนโลยี'),
  math(label: 'คณิตศาสตร์'),
  language(label: 'ภาษาต่างประเทศ'),
  social(label:'สังคมศาสตร์'),
  art(label: 'ศิลปะ'),
  physical(label: 'สุขศึกษา');

  final String label;
  const AcademicDepartment({required this.label});
}

enum Division {
  budget(label:'ฝั่งงบประมาณ');
  // TODO: มีเยอะกว่านี้แต่ยังคิดไม่ออก
  final String label;
  const Division({required this.label});
}

enum EmployeeStatus {
  director(label: 'ผู้อำนวยการ/ผู้บริหาร'),
  deputyDirector(label: 'รองผู้อำนวยการ/รองผู้บริหาร'),
  civilServant(label: 'ข้าราชการ'),
  governmentEmployee(label: 'พนักงานราชการ'),
  contractTeacher(label: 'ครูอัตราจ้าง'),
  permanentEmployee(label: 'ลูกจ้างประจำ'),
  temporaryEmployee(label: 'ลูกจ้างชั่วคราว'),
  officeStaff(label: 'เจ้าหน้าที่สำนักงาน'),
  developer(label: 'นักพัฒนา'),
  driver(label: 'พนักงานขับรถ');

  final String label;
  const EmployeeStatus({required this.label});
}

class User {
  final String id;
  final String username;
  String password;
  String image;
  String firstname;
  String lastname;
  String phone;
  AcademicDepartment academicDepartment;
  Division division;
  String homeroomClass;
  EmployeeStatus employeeStatus;
  final String role; // admin, user

  User({
    required this.id,
    required this.username,
    required this.password,
    this.image = "user.png",
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.academicDepartment,
    required this.division,
    required this.homeroomClass,
    required this.employeeStatus,
    required this.role
  });

  static Future<User> create({
    required String id,
    required String username,
    required String rawPassword,
    String image = "user.png",
    required String firstname,
    required String lastname,
    required String phone,
    required AcademicDepartment academicDepartment,
    required Division division,
    required String homeroomClass,
    required EmployeeStatus employeeStatus,
    required String role
  }) async {
    final hashedPassword = await PasswordService.hashPassword(rawPassword);
    return User(
      id: id,
      username: username,
      password: hashedPassword,
      firstname: firstname,
      lastname: lastname,
      image: image,
      phone: phone,
      academicDepartment: academicDepartment,
      division: division,
      homeroomClass: homeroomClass,
      employeeStatus: employeeStatus,
      role: role
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(),
      username: map['username'],
      password: map['password'],
      image: map['image'] ?? "user.png",
      firstname: map['firstname'],
      lastname: map['lastname'],
      phone: map['phone'],
      academicDepartment: AcademicDepartment.values.firstWhere((e) => e.name == map['academic_department']),
      division: Division.values.firstWhere((e) => e.name == map['division']),
      homeroomClass: map['homeroom_class'] ?? '',
      employeeStatus: EmployeeStatus.values.firstWhere((e) => e.name == map['employee_status']),
      role: map['role'] ?? "user",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'image': image,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'academic_department': academicDepartment.name,
      'division': division.name,
      'homeroom_class': homeroomClass,
      'employee_status': employeeStatus.name,
    };
  }

  bool get isAdmin => role == "admin";

  String get fullname => "$firstname $lastname";

  set name(String value) {
    var parts = value.split(" ");
    firstname = parts[0];
    if (parts.length > 1) lastname = parts[1];
  }
}
