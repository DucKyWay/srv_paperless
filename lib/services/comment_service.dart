  import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/comment_model.dart';
import 'package:srv_paperless/data/repositories/comment_repo.dart';

class CommentService {
  final CommentRepository commentRepo;

  CommentService(this.commentRepo);

  Future<List<Comment>> getCommentsByProjectId(String projectId) async {
    return await commentRepo.fetchCommentsByProjectId(projectId);
  }
}

final commentsServiceProvider = Provider<CommentService>((ref) {
  final repo = ref.watch(commentRepoProvider);
  return CommentService(repo);
});
