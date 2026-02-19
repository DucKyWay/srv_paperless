import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/project_model.dart';

abstract class ProjectRepository {
  Future<List<Project>> fetchAllProjects();
  Future<Project?> fetchProjectById(String id);
  Future<List<Project>> fetchProjectsByChairman(String name);
  Future<List<Project>> fetchProjectsByStatus(String status);
  Future<List<Project>> fetchProjectDraftByUserId(String id);
  Future<int> create(Project project);
  Future<int> update(String id, Project project);
  Future<int> delete(String id);
}

class ProjectRepositoryImpl implements ProjectRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  @override
  Future<List<Project>> fetchAllProjects() async {
    final snapshot = await _db.collection('projects').get();
    return snapshot.docs
        .map((doc) => Project.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<Project?> fetchProjectById(String id) async {
    final doc = await _db.collection('projects').doc(id).get();
    return doc.exists ? Project.fromMap(doc.data()!, doc.id) : null;
  }

  @override
  Future<List<Project>> fetchProjectsByChairman(String name) async {
    final snapshot =
        await _db
            .collection('projects')
            .where('chairman', isEqualTo: name)
            .get();

    return snapshot.docs
        .map((doc) => Project.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<Project>> fetchProjectsByStatus(String status) async {
    final snapshot =
        await _db
            .collection('projects')
            .where('status', isEqualTo: status)
            .get();

    return snapshot.docs
        .map((doc) => Project.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
Future<int> create(Project project) async {
  try {
    final docRef = _db.collection('projects').doc(); 
    final finalProject = project.copyWith(id: docRef.id);
    await docRef.set(finalProject.toMap());

    return 0;
  } catch (e) {
    return 1;
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
      final project = await fetchProjectById(id);

      if (project != null) {
        await _db.collection('projects').doc(id).delete();
        return 0;
      } else {
        return 1;
      }
    } catch (e) {
      return 1;
    }
  }
  
  @override
  Future<List<Project>> fetchProjectDraftByUserId(String id) async{
    final snapshot =
        await _db
            .collection('projects')
            .where('user_id', isEqualTo: id)
            .where('status',isEqualTo: 'draft')
            .get();

    return snapshot.docs
        .map((doc) => Project.fromMap(doc.data(), doc.id))
        .toList();
  }
}

final projectRepoProvider = Provider<ProjectRepository>(
  (ref) => ProjectRepositoryImpl(),
);
