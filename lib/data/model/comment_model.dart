class Comment {
  final String id;
  final String userId;
  final String projectId;
  final String message;
  String? commentCreatedAt;

  Comment({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.message,
    this.commentCreatedAt,
  });

  Comment copyWith({
    String? id,
    String? userId,
    String? projectId,
    String? message,
    String? commentCreatedAt
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
      commentCreatedAt: map['comment_created_at'],
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
