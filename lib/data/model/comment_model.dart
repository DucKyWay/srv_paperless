import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String? id;
  final String userId;
  final String projectId;
  final String message;
  final DateTime? commentCreatedAt;

  Comment({
    this.id,
    required this.userId,
    required this.projectId,
    required this.message,
    required this.commentCreatedAt,
  });

  Comment copyWith({
    String? id,
    String? userId,
    String? projectId,
    String? message,
    DateTime? commentCreatedAt
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      message: message ?? this.message,
      commentCreatedAt: commentCreatedAt ?? this.commentCreatedAt
    );
  }

  factory Comment.fromMap(Map<String, dynamic> map, String docId) {
    return Comment(
      id: docId,
      userId: map['user_id'],
      projectId: map['project_id'],
      message: map['message'],
      commentCreatedAt: (map['comment_created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'project_id': projectId,
      'message': message,
      'comment_created_at': commentCreatedAt,
    };
  }
}
