import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/project_model.dart';

abstract class ProjectRepository{
  Future<List<Project>> fetchAllProjects();
  Future<List<Project?>?> fetchProjectApproved();
  Future<List<Project?>?> fetchProjectRejected();
  Future<List<Project?>?> fetchProjectDraftByUserId(String userId);
  Future<List<Project?>?> fetchProjectSuccess();
  Future<Project?> fetchProjectById(String id);
  Future<int> updateProject(String uid,Project Project);
}

class ProjectRepositoryImpl implements ProjectRepository{
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  @override
  Future<List<Project>> fetchAllProjects() async{
    final snapshot = await _db.collection('projects').get();
    return snapshot.docs
        .map((doc)=>Project.fromMap(doc.data(),doc.id))
        .toList();

  }
  @override
  Future<List<Project?>?> fetchProjectApproved() async {
    final snapshot = await _db.collection('projects')
      .where('status', isEqualTo: 'approved')
      .get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.map((doc) {
      return Project.fromMap(doc.data(), doc.id);
    }).toList();
  }
  @override
  Future<Project?> fetchProjectById(String id)async{
    final doc = await _db.collection('projects').doc(id).get();
    return doc.exists? Project.fromMap(doc.data()!, doc.id) :null;
  }

  @override
  Future<List<Project?>?> fetchProjectDraftByUserId(String userId) async{
    final snapshot = await _db.collection('projects')
      .where('status', isEqualTo: 'draft')
      .where('user_id',isEqualTo: userId)
      .get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.map((doc) {
      return Project.fromMap(doc.data(), doc.id);
    }).toList();
  }

  @override
  Future<List<Project?>?> fetchProjectRejected() async{
    final snapshot = await _db.collection('projects')
      .where('status', isEqualTo: 'reject')
      .get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.map((doc) {
      return Project.fromMap(doc.data(), doc.id);
    }).toList();
  }

  @override
  Future<int> updateProject(String uid, Project project) async{
    try {
      await _db.collection('projects').doc(uid).update(project.toMap());
      return 0;    
    } catch (e) {
      return 1;
    }
  }
  
  @override
  Future<List<Project?>?> fetchProjectSuccess() async{
    final snapshot = await _db.collection('projects')
      .where('status', isEqualTo: 'success')
      .get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.map((doc) {
      return Project.fromMap(doc.data(), doc.id);
    }).toList();
  }
}
final projectRepoProvider = Provider<ProjectRepository>(
  (ref) =>ProjectRepositoryImpl(),
);