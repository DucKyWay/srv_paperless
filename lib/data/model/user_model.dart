class User {
  final String id;
  final String username;
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

  User copyWith({String? id, String? image}) {
    return User(
      id: id ?? this.id,
      username: username,
      image: image ?? this.image,
      firstname: firstname,
      lastname: lastname,
      phone: phone,
      academicDepartment: academicDepartment,
      divisions: divisions,
      homeroomClass: homeroomClass,
      employeeStatus: employeeStatus,
      role: role,
    );
  }

  factory User.fromMap(Map<String, dynamic> map, String docId) {
    return User(
      id: docId,
      username: map['username']?.toString() ?? '',
      image: map['image'] ?? "user.png",
      firstname: map['firstname']?.toString() ?? '',
      lastname: map['lastname']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      academicDepartment: map['academic_department']?.toString() ?? '',
      divisions: map['divisions']?.toString() ?? '',
      homeroomClass: map['homeroom_class']?.toString() ?? '',
      employeeStatus: map['employee_status']?.toString() ?? '',
      role: map['role'] ?? "user",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'image': image,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'academic_department': academicDepartment,
      'divisions': divisions,
      'homeroom_class': homeroomClass,
      'employee_status': employeeStatus,
      'role': role
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
