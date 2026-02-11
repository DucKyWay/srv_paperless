class EmployeeStatusModel {
  final String id;
  final String key;
  final String label;

  EmployeeStatusModel({
    required this.id,
    required this.key,
    required this.label,
  });

  factory EmployeeStatusModel.fromMap(Map<String, dynamic> map) {
    return EmployeeStatusModel(
      id: map['e_status_id'],
      key: map['e_status_key'],
      label: map['e_status_label'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'e_status_id': id, 'e_status_key': key, 'e_status_label': label};
  }
}
