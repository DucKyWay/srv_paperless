class DivisionsModel {
  final String id;
  final String key;
  final String label;

  DivisionsModel({required this.id, required this.key, required this.label});

  factory DivisionsModel.fromMap(Map<String, dynamic> map) {
    return DivisionsModel(
      id: map['division_id'],
      key: map['division_key'],
      label: map['division_label'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'division_id': id, 'division_key': key, 'division_label': label};
  }
}
