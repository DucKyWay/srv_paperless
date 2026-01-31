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

class User {
  final String id;        // ตัวแปรที่เป็น final ไม่ต้องมี _ ก็นำหน้าได้ถ้าไม่ซีเรียสเรื่อง private
  final String username;
  String image;
  String fullname;
  String phone;
  AcademicDepartment academicDepartment;
  Division division;
  String homeroomClass;
  EmployeeStatus employeeStatus;

  User({
    required this.id,
    required this.username,
    this.image = "user.png",
    required this.fullname,
    required this.phone,
    required this.academicDepartment,
    required this.division,
    required this.homeroomClass,
    required this.employeeStatus,
  });

  // ใช้ setter แบบสากล
  set phoneNo(String value) => phone = value;
  set name(String value) => fullname = value;
}