import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/comment_model.dart';
import 'package:srv_paperless/data/repositories/comment_repo.dart';

class CommentService {
  final CommentRepository commentRepo;

  CommentService(this.commentRepo);

  Future<int> createComment(Comment comment) async {
    try {
      await commentRepo.create(comment);
      return 0;
    } catch (e) {
      return 1;
    }
  }

  Future<int> updateComment(String id, Comment comment) async {
    try {
      await commentRepo.update(id, comment);
      return 0;
    } catch (e) {
      return 1;
    }
  }

  Future<int> deleteComment(String id) async {
    try {
      await commentRepo.delete(id);
      return 0;
    } catch (e) {
      return 1;
    }
  }

  Future<List<Comment>> getAllComments() async {
    return await commentRepo.fetchAllComments();
  }

  Future<List<Comment>> getCommentsByProjectId(String projectId) async {
    return await commentRepo.fetchCommentsByProjectId(projectId);
  }

  Future<Comment?> getLatestCommentByProjectId(String projectId) async {
    try {
      final comments = await commentRepo.fetchCommentsByProjectId(projectId);
      return comments.isNotEmpty ? comments.first : null;
    } catch (e) {
      print("Error in getLatestComment: $e");
      return null;
    }
  }
}

final commentsServiceProvider = Provider<CommentService>((ref) {
  final repo = ref.watch(commentRepoProvider);
  return CommentService(repo);
});
