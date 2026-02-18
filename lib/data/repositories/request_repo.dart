import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/request_model.dart';

abstract class RequestRepository {
  Future<List<Request>> fetchAllRequests();
  Future<Request?> fetchRequestById(String id);
  Future<List<Request>> fetchRequestsByChairman(String name);
  Future<List<Request>> fetchRequestsByStatus(String status);

  Future<int> create(Request request);
  Future<int> update(String id, Request request);
  Future<int> delete(String id);
}

class RequestRepositoryImpl implements RequestRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  @override
  Future<List<Request>> fetchAllRequests() async {
    final snapshot = await _db.collection('projects').get();
    return snapshot.docs
        .map((doc) => Request.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<Request?> fetchRequestById(String id) async {
    final doc = await _db.collection('projects').doc(id).get();
    return doc.exists ? Request.fromMap(doc.data()!, doc.id) : null;
  }

  @override
  Future<List<Request>> fetchRequestsByChairman(String name) async {
    final snapshot =
        await _db
            .collection('projects')
            .where('chairman', isEqualTo: name)
            .get();

    return snapshot.docs
        .map((doc) => Request.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<Request>> fetchRequestsByStatus(String status) async {
    final snapshot =
        await _db
            .collection('projects')
            .where('status', isEqualTo: status)
            .get();

    return snapshot.docs
        .map((doc) => Request.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<int> create(Request request) async {
    try {
      final newRequest = request.copyWith(id: request.id);
      await _db
          .collection('projects')
          .doc(newRequest.id)
          .set(newRequest.toMap());

      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> update(String id, Request request) async {
    try {
      await _db.collection('projects').doc(id).update({
        'id': request.id,
        'project_name': request.projectName,
        'chairman': request.chairman,
        'date': request.date,
        'budget': request.budget,
        'pdf_path': request.pdfPath,
        'status': request.status,
      });
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> delete(String id) async {
    try {
      final request = await fetchRequestById(id);

      if (request != null) {
        await _db.collection('projects').doc(id).delete();
        return 0;
      } else {
        return 1;
      }
    } catch (e) {
      return 1;
    }
  }
}

final requestRepoProvider = Provider<RequestRepository>(
  (ref) => RequestRepositoryImpl(),
);
