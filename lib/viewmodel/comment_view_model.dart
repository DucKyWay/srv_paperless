import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/comment_model.dart';
import 'package:srv_paperless/services/comment_service.dart';

final commentProvider = AsyncNotifierProvider<CommentViewModel, void>(
  CommentViewModel.new,
);

class CommentViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createComment(
    String userId,
    String projectId,
    String message,
  ) async {
    final comment = Comment(
      userId: userId,
      projectId: projectId,
      message: message,
      commentCreatedAt: DateTime.now(),
    );

    int success = await ref
        .read(commentsServiceProvider)
        .createComment(comment);
    _refreshComments();
    if (success == 0) {
      print("Crate commented");
    } else {
      print("Failed to create comment");
    }
  }

  Future<void> updateComment(
    String id,
    String userId,
    String projectId,
    String message,
    DateTime commentCreatedAt,
  ) async {
    if (id.isEmpty || userId.isEmpty || projectId.isEmpty || message.isEmpty) {
      print("Parameter cannot empty");
    } else {
      final comment = Comment(
        userId: userId,
        projectId: projectId,
        message: message,
        commentCreatedAt: commentCreatedAt,
      );

      await ref.read(commentsServiceProvider).updateComment(id, comment);
      _refreshComments();
    }
  }

  Future<void> deleteComment(String id) async {
    if (id.isEmpty) {
      print("ID cannot empty");
    } else {
      await ref.read(commentsServiceProvider).deleteComment(id);
      _refreshComments();
    }
  }

  void _refreshComments() {
    ref.invalidate(allComments);
    ref.invalidate(commentsByProjectId);
    ref.invalidate(latestCommentByProjectId);
  }
}

final allComments = FutureProvider<List<Comment>>((ref) {
  ref.keepAlive();
  return ref.watch(commentsServiceProvider).getAllComments();
});

final commentsByProjectId = FutureProvider.family<List<Comment>, String>((
  ref,
  id,
) {
  // ref.keepAlive();
  print("FETCHING START for ID: $id");
  ref.watch(commentProvider);
  return ref.watch(commentsServiceProvider).getCommentsByProjectId(id);
});

final latestCommentByProjectId = FutureProvider.family<Comment?, String>((
  ref,
  id,
) {
  ref.keepAlive();
  ref.watch(commentProvider);
  return ref.watch(commentsServiceProvider).getLatestCommentByProjectId(id);
});
