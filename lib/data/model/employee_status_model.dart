class EmployeeStatus {
  final int id;
  final String key;
  final String label;

  EmployeeStatus({
    required this.id,
    required this.key,
    required this.label,
  });

  factory EmployeeStatus.fromMap(Map<String, dynamic> map) {
    return EmployeeStatus(
      id: map['e_status_id'] as int,
      key: map['e_status_key'].toString(),
      label: map['e_status_label'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'e_status_id': id, 'e_status_key': key, 'e_status_label': label};
  }
}
