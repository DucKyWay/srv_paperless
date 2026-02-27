import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/employee_status_model.dart';

abstract class EmployeeStatusRepository {
  Future<List<EmployeeStatus>> fetchAllEmployeeStatus();
  Future<EmployeeStatus?> fetchEmployeeStatusById(String id);
  Future<EmployeeStatus?> fetchEmployeeStatusByKey(String key);
  Future<int> create(EmployeeStatus es);
  Future<int> update(String uid, EmployeeStatus newEs);
  Future<int> delete(String uid);
}

class EmployeeStatusRepositoryImpl implements EmployeeStatusRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<EmployeeStatus?> fetchEmployeeStatusById(String id) async {
    final doc = await _db.collection('employee_status').doc(id).get();

    if (doc.exists) {
      return EmployeeStatus.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<EmployeeStatus?> fetchEmployeeStatusByKey(String key) async {
    final snapshot = await _db
        .collection('employee_status')
        .where('key', isEqualTo: key)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return EmployeeStatus.fromMap(doc.data(), doc.id);
    }
    return null;
  }

  @override
  Future<List<EmployeeStatus>> fetchAllEmployeeStatus() async {
    final snapshot = await _db.collection('employee_status').get();

    return snapshot.docs.map((doc) {
      return EmployeeStatus.fromMap(doc.data(), doc.id);
    }).toList();
  }
  
  @override
  Future<int> create(EmployeeStatus es) async {
    try {
      final doc = _db.collection('employee_status').doc();
      final newEs = es.copyWith(id: doc.id);
      await doc.set(newEs.toMap());
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> delete(String uid) async {
    try {
      final es = await fetchEmployeeStatusById(uid);

      if(es != null) {
        await _db.collection('employee_status').doc(uid).delete();
        return 0;
      } else {
        return 1;
      }
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> update(String uid, EmployeeStatus newEs) async {
    try {
      await _db.collection('employee_status').doc(uid).update(newEs.toMap());
      return 0;
    } catch (e) {
      return 1;
    }
  }
}

final employeeStatusRepoProvider = Provider<EmployeeStatusRepository>(
  (ref) => EmployeeStatusRepositoryImpl(),
);