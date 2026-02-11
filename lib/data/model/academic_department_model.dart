class AcademicDepartment {
  final String id;
  final String key;
  final String label;

  AcademicDepartment({
    required this.id,
    required this.key,
    required this.label,
  });

  factory AcademicDepartment.fromMap(Map<String, dynamic> map) {
    return AcademicDepartment(
      id: map['a_department_id'],
      key: map['a_department_key'],
      label: map['a_department_label'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'a_department_id': id,
      'a_department_key': key,
      'a_department_label': label,
    };
  }
}
