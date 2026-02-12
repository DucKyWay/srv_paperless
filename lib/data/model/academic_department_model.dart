class AcademicDepartment {
  final String id;
  final String key;
  final String label;

  AcademicDepartment({
    required this.id,
    required this.key,
    required this.label,
  });

  factory AcademicDepartment.fromMap(Map<String, dynamic> map, String docId) {
    return AcademicDepartment(
      id: docId, 
      key: map['key']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'label': label,
    };
  }
}