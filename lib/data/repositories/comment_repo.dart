import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/comment_model.dart';

abstract class CommentRepository {
  Future<Comment?> fetchCommentById(String id);
  Future<List<Comment>> fetchCommentsByProjectId(String projectId);
  Future<int> create(Comment newComment);
  Future<int> update(String id, Comment updateComment);
  Future<int> delete(String id);
}

class CommentRepositoryImpl implements CommentRepository {
  final _db = FirebaseFirestore.instance;

  @override
  Future<int> create(Comment comment) async {
    try {
      final newComment = comment.copyWith(id: comment.id);
      await _db
          .collection('comments')
          .doc(newComment.id)
          .set(newComment.toMap());
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> delete(String id) async {
    try {
      final comment = await fetchCommentById(id);

      if (comment != null) {
        await _db.collection('comments').doc(id).delete();
        return 0;
      } else {
        return 1;
      }
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<Comment?> fetchCommentById(String id) async {
    final doc = await _db.collection('comments').doc(id).get();
    return doc.exists ? Comment.fromMap(doc.data()!, doc.id) : null;
  }

  @override
  Future<List<Comment>> fetchCommentsByProjectId(String projectId) async {
    final snapshot =
        await _db
            .collection('comments')
            .where('project_id', isEqualTo: projectId)
            .get();
    return snapshot.docs
        .map((doc) => Comment.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<int> update(String id, Comment updateComment) async {
    try {
      await _db.collection('comments').doc(id).update(updateComment.toMap());
      return 0;
    } catch (e) {
      return 1;
    }
  }
}

final commentRepoProvider = Provider<CommentRepository>(
  (ref) => CommentRepositoryImpl(),
);
