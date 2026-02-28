class Divisions {
  String? id;
  final String key;
  final String label;

  Divisions({this.id, required this.key, required this.label});

  Divisions copyWith({String? id, String? key, String? label}) {
    return Divisions(
      id: id ?? this.id,
      key: key ?? this.key,
      label: label ?? this.label,
    );
  }

  factory Divisions.fromMap(Map<String, dynamic> map, String docId) {
    return Divisions(
      id: docId,
      key: map['key'].toString(),
      label: map['label'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'key': key, 'label': label};
  }
}
