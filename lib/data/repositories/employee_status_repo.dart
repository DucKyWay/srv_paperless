import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/employee_status_model.dart';

abstract class EmployeeStatusRepository {
  Future<List<EmployeeStatus>> fetchAllEmployeeStatus();
  Future<EmployeeStatus?> fetchEmployeeStatusById(String id);
  Future<EmployeeStatus?> fetchEmployeeStatusByKey(String key);
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
}

final employeeStatusRepoProvider = Provider<EmployeeStatusRepository>(
  (ref) => EmployeeStatusRepositoryImpl(),
);

// ===== Provider =====

final getAllEmployeeStatus = FutureProvider<List<EmployeeStatus>>((ref) async {
  final repo = ref.watch(employeeStatusRepoProvider);
  return await repo.fetchAllEmployeeStatus();
});

final getEmployeeStatusByKey = FutureProvider.family<EmployeeStatus?, String>((
  ref,
  key,
) async {
  final repo = ref.watch(employeeStatusRepoProvider);
  return await repo.fetchEmployeeStatusByKey(key);
});
