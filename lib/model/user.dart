enum AcademicDepartment{
  science(label:'วิทยาศาสตร์และเทคโนโลยี'), 
  math(label: 'คณิตศาสตร์'),
  language(label: 'ภาษาต่างประเทศ'),
  social(label:'สังคมศาสตร์'),
  art(label: 'ศิลปะ');
  final String label;
  const AcademicDepartment({required this.label});
}

enum Division{
  budget(label:'ฝั่งงบประมาณ');
  /* มีเยอะกว่านี้แต่ยังคิดไม่ออก */
  final String label;
  const Division({required this.label});
}

enum EmployeeStatus{
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

class User{
  final String _id;
  final String _username;
  String _image;
  String _fullname;
  String _phone;
  AcademicDepartment _academicDepartment;
  Division _division;
  String _homeroomClass;
  EmployeeStatus _employeeStatus;

  User(
    this._id,
    this._username,
    this._image,
    this._fullname,
    this._phone,
    this._academicDepartment,
    this._division,
    this._homeroomClass,
    this._employeeStatus
  );

  String get id => _id;
  String get image => _image;
  String get phone => _phone;
  String get username=>_username;
  String get fullname =>_fullname;
  AcademicDepartment get academicDepartment => _academicDepartment;
  Division get division => _division;
  String get homeroomClass => _homeroomClass;
  EmployeeStatus get employeeStatus => _employeeStatus;
  
  set setImage(String value) => _image = value;
  set setPhone(String value) =>_phone = value;
  set setFullname(String value) => _fullname = value;
  set setAcademicDepartment(AcademicDepartment value) => _academicDepartment = value;
  set setDivision(Division value) => _division = value;
  set setHomeroomClass(String value) => _homeroomClass = value;
  set setEmployeeStatus(EmployeeStatus value) => _employeeStatus = value;
}