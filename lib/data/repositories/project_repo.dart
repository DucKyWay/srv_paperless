import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/project_model.dart';

abstract class ProjectRepository {
  Future<List<Project>> fetchAllProjects();
  Future<Project?> fetchProjectById(String id);
  Future<List<Project>> fetchProjectsByChairman(String name);
  Future<List<Project>> fetchProjectsByStatus(
    String status, {
    String? budgetYear,
  });
  Future<List<Project>> fetchProjectDraftByUserId(String id);
  Future<Project?> create(Project project);
  Future<int> update(String id, Project project);
  Future<int> delete(String id);
  Future<int> updateProjectFile(String id, String name);
}

class ProjectRepositoryImpl implements ProjectRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  @override
  Future<List<Project>> fetchAllProjects() async {
    try {
      final snapshot =
          await _db
              .collection('projects')
              .orderBy('fix_latest', descending: true)
              .limit(50)
              .get();

      return snapshot.docs
          .map((doc) => Project.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Project?> fetchProjectById(String id) async {
    try {
      final doc = await _db.collection('projects').doc(id).get();
      return doc.exists ? Project.fromMap(doc.data()!, doc.id) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Project>> fetchProjectsByChairman(String name) async {
    final snapshot =
        await _db
            .collection('projects')
            .where('chairman', isEqualTo: name)
            .orderBy('fix_latest', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => Project.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<Project>> fetchProjectsByStatus(
    String status, {
    String? budgetYear,
  }) async {
    Query query = _db.collection('projects').where('status', isEqualTo: status);

    if (budgetYear != null && budgetYear.isNotEmpty) {
      query = query.where('budget_year', isEqualTo: budgetYear);
    }

    final snapshot = await query.orderBy('fix_latest', descending: true).get();

    return snapshot.docs
        .map(
          (doc) => Project.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  @override
  Future<Project?> create(Project project) async {
    try {
      final docRef = _db.collection('projects').doc();
      final finalProject = project.copyWith(id: docRef.id);
      await docRef.set(finalProject.toMap());
      return finalProject;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> update(String id, Project project) async {
    try {
      await _db.collection('projects').doc(id).update(project.toMap());
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> delete(String id) async {
    try {
      await _db.collection('projects').doc(id).delete();
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<List<Project>> fetchProjectDraftByUserId(String id) async {
    try {
      final snapshot =
          await _db
              .collection('projects')
              .where('user_id', isEqualTo: id)
              .where('status', isEqualTo: 'draft')
              .orderBy('fix_latest', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => Project.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<int> updateProjectFile(String id, String name) async {
    try {
      await _db.collection('projects').doc(id).update({'pdf_path': name});
      return 0;
    } catch (e) {
      return 1;
    }
  }
}

final projectRepoProvider = Provider<ProjectRepository>(
  (ref) => ProjectRepositoryImpl(),
);
