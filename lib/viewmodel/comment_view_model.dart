import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/comment_model.dart';
import 'package:srv_paperless/data/repositories/comment_repo.dart';

final commentProvider = AsyncNotifierProvider<CommentViewModel, void>(CommentViewModel.new);

class CommentViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Comment?> getCommentById(String id) async {
    if (id.isEmpty) return null;

    try {
      return await ref.read(commentRepoProvider).fetchCommentById(id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Comment>> getCommentsByProjectId(String projectId) async {
    if (projectId.isEmpty) return [];

    try {
      return await ref
          .read(commentRepoProvider)
          .fetchCommentsByProjectId(projectId);
    } catch (e) {
      return [];
    }
  }

  Future<void> createComment(
    String userId,
    String projectId,
    String message,
  ) async {
    final comment = Comment(
      userId: userId,
      projectId: projectId,
      message: message,
      commentCreatedAt: DateTime.now().toString()
    );

    int success = await ref.read(commentRepoProvider).create(comment);

    if(success == 0) {
      print("Crate commented"); 
    } else {
      print("Failed to create comment");
    }
  }

  Future<void> updateComment(String id, String userId, String projectId, String message) async {
    if(id.isEmpty || userId.isEmpty || projectId.isEmpty || message.isEmpty) {
      print("Parameter cannot empty");
    } else {
      final comment = Comment(
        userId: userId,
        projectId: projectId,
        message: message
      );

      await ref.read(commentRepoProvider).update(id, comment);
    }

  }

  Future<void> deleteComment(String id) async {
    if(id.isEmpty) {
      print("ID cannot empty");
    } else {
      await ref.read(commentRepoProvider).delete(id);
    }
  }
}
