class AcademicDepartment {
  String? id;
  final String key;
  final String label;

  AcademicDepartment({
    this.id,
    required this.key,
    required this.label,
  });

  AcademicDepartment copyWith({String? id, String? key, String? label}) {
    return AcademicDepartment(
      id: id ?? this.id,
      key: key ?? this.key,
      label: label ?? this.label,
    );
  }

  factory AcademicDepartment.fromMap(Map<String, dynamic> map, String docId) {
    return AcademicDepartment(
      id: docId,
      key: map['key']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'key': key, 'label': label};
  }
}
