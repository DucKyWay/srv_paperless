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
  final String _fullname;
  final AcademicDepartment _academicDepartment;
  final Division _division;
  final String _homeroomClass;
  final EmployeeStatus _employeeStatus;

  User(
    this._id,
    this._username,
    this._fullname,
    this._academicDepartment,
    this._division,
    this._homeroomClass,
    this._employeeStatus
  );

  String get id => _id;
  String get username=>_username;
  String get fullname =>_fullname;
  AcademicDepartment get academicDepartment => _academicDepartment;
  Division get division => _division;
  String get homeroomClass => _homeroomClass;
  EmployeeStatus get employeeStatus => _employeeStatus;

}