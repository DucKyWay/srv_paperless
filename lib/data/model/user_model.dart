import 'package:srv_paperless/data/model/academic_department_model.dart';
import 'package:srv_paperless/data/model/divisions_model.dart';
import 'package:srv_paperless/data/model/employee_status_model.dart';

class User {
  final String id;
  final String username;
  String password;
  String image;
  String firstname;
  String lastname;
  String phone;
  String academicDepartment;
  String divisions;
  String employeeStatus;
  String homeroomClass;
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
    required this.divisions,
    required this.homeroomClass,
    required this.employeeStatus,
    required this.role
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(),
      username: map['username'],
      password: map['password'],
      image: map['image'] ?? "user.png",
      firstname: map['firstname'],
      lastname: map['lastname'],
      phone: map['phone'],
      academicDepartment: map['academic_department'],
      divisions: map['divisions'],
      homeroomClass: map['homeroom_class'] ?? '',
      employeeStatus: map['employee_status'],
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
      'academic_department': academicDepartment,
      'divisions': divisions,
      'homeroom_class': homeroomClass,
      'employee_status': employeeStatus,
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
