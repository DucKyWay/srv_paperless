class Request {
  final String id;
  final String? projectName;
  final String? chairman;
  final String? date;
  final double? budget;
  final String? pdfPath;
  String? status; // 'draft' หรือ 'submitted'

  Request({
    required this.id,
    required this.projectName,
    required this.chairman,
    required this.date,
    required this.budget,
    required this.pdfPath,
    this.status = 'draft',
  });

  Request copyWith({
    String? id,
    String? projectName,
    String? chairman,
    String? date,
    double? budget,
    String? pdfPath,
    String? status,
  }) {
    return Request(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      chairman: chairman ?? this.chairman,
      date: date ?? this.date,
      budget: budget ?? this.budget,
      pdfPath: pdfPath ?? this.pdfPath,
      status: status ?? this.status
    );
  }

  factory Request.fromMap(Map<String, dynamic> map, String docId) {
    return Request(
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
