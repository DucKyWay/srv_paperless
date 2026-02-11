class Divisions {
  final int id;
  final String key;
  final String label;

  Divisions({required this.id, required this.key, required this.label});

  factory Divisions.fromMap(Map<String, dynamic> map) {
    return Divisions(
      id: map['division_id'] as int,
      key: map['division_key'].toString(),
      label: map['division_label'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'division_id': id, 'division_key': key, 'division_label': label};
  }
}
