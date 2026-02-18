class Project {
  final String id;
  final String? projectName;
  final String? chairman;
  final String? date;
  final double? budget;
  final String? pdfPath;
  String? status; // 'draft' หรือ 'submitted'

  Project({
    required this.id,
    required this.projectName,
    required this.chairman,
    required this.date,
    required this.budget,
    required this.pdfPath,
    this.status = 'draft',
  });

  Project copyWith({
    String? id,
    String? projectName,
    String? chairman,
    String? date,
    double? budget,
    String? pdfPath,
    String? status,
  }) {
    return Project(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      chairman: chairman ?? this.chairman,
      date: date ?? this.date,
      budget: budget ?? this.budget,
      pdfPath: pdfPath ?? this.pdfPath,
      status: status ?? this.status
    );
  }

  factory Project.fromMap(Map<String, dynamic> map, String docId) {
    return Project(
      id: docId,
      projectName: map['project_name']?.toString(),
      chairman: map['chairman'],
      date: map['date'],
      budget: map['budget'],
      pdfPath: map['pdf_path'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'project_name': projectName,
      'chairman': chairman,
      'date': date,
      'budget': budget,
      'pdf_path': pdfPath,
      'status': status,
    };
  }
}
