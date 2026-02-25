import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:srv_paperless/core/constants/project_status_enum.dart';

class Project {
  final String id;
  final String userId;
  final String? projectName;
  final String? chairman;
  final DateTime? date;
  final double? budget;
  final String? pdfPath;
  final DateTime? fixLatest;
  ProjectStatus status;

  Project({
    required this.id,
    required this.userId,
    required this.projectName,
    required this.chairman,
    required this.date,
    required this.budget,
    this.pdfPath,
    required this.fixLatest,
    this.status = ProjectStatus.draft,
  });

  Project copyWith({
    String? id,
    String? userId,
    String? projectName,
    String? chairman,
    DateTime? date,
    double? budget,
    String? pdfPath,
    DateTime? fixLatest,
    ProjectStatus? status,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectName: projectName ?? this.projectName,
      chairman: chairman ?? this.chairman,
      date: date ?? this.date,
      budget: budget ?? this.budget,
      fixLatest: fixLatest ?? this.fixLatest,
      pdfPath: pdfPath ?? this.pdfPath,
      status: status ?? this.status,
    );
  }

  factory Project.fromMap(Map<String, dynamic> map, String docId) {
    return Project(
      id: docId,
      date: (map['date'] as Timestamp?)?.toDate(),
      fixLatest: (map['fix_latest'] as Timestamp?)?.toDate(),
      userId: map['user_id'].toString(),
      projectName: map['project_name']?.toString(),
      chairman: map['chairman'],
      budget: map['budget'],
      pdfPath: map['pdf_path'],
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ProjectStatus.draft,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'project_name': projectName,
      'chairman': chairman,
      'date': date,
      'budget': budget,
      'pdf_path': pdfPath,
      'fix_latest': fixLatest,
      'status': status.name,
    };
  }
}
