class EmployeeStatus {
  final String id;
  final String key;
  final String label;

  EmployeeStatus({required this.id, required this.key, required this.label});

  EmployeeStatus copyWith({String? id, String? key, String? label}) {
    return EmployeeStatus(
      id: id ?? this.id,
      key: key ?? this.key,
      label: label ?? this.label,
    );
  }

  factory EmployeeStatus.fromMap(Map<String, dynamic> map, String docId) {
    return EmployeeStatus(
      id: docId,
      key: map['key']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'key': key, 'label': label};
  }
}
