import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/project_location_model.dart';

abstract class ProjectLocationRepository {
  Future<List<ProjectLocation>> fetchAllProjectLocationById(String id);
  Future<int> create(ProjectLocation newProjectLocation);
  Future<int> update(String id, ProjectLocation updateProjectLocation);
  Future<int> delete(String id);
}

class ProjectLocationRepositoryImpl implements ProjectLocationRepository {
  final _db = FirebaseFirestore.instance;

  @override
  Future<List<ProjectLocation>> fetchAllProjectLocationById(String id) async {
    try {
      final snapshot = await _db.collection('project_locations')
          .where('request_id', isEqualTo: id)
          .get();
      return snapshot.docs
          .map((doc) => ProjectLocation.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<int> create(ProjectLocation newProjectLocation) async {
    try {
      final docRef = _db.collection('project_locations').doc();
      final finalProjectLocation = newProjectLocation.copyWith(id: docRef.id);
      await docRef.set(finalProjectLocation.toMap());
      return 1;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> delete(String id) async {
    try {
      await _db.collection('project_locations').doc(id).delete();
      return 1;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> update(String id, ProjectLocation updateProjectLocation) async {
    try {
      await _db.collection('project_locations').doc(id).update(updateProjectLocation.toMap());
      return 1;
    } catch (e) {
      return 0;
    }
  }
}

final projectLocationRepoProvider = Provider<ProjectLocationRepository>(
  (ref) => ProjectLocationRepositoryImpl(),
);
