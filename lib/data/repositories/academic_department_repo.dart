import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/academic_department_model.dart';

abstract class AcademicDepartmentRepository {
  Future<List<AcademicDepartment>> fetchAllAcademicDepartments();
  Future<AcademicDepartment?> fetchAcademicDepartmentById(String id);
  Future<AcademicDepartment?> fetchAcademicDepartmentByKey(String key);
}

class AcademicDepartmentRepositoryImpl implements AcademicDepartmentRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<AcademicDepartment?> fetchAcademicDepartmentById(String id) async {
    final doc = await _db.collection('academic_department').doc(id).get();

    if (doc.exists) {
      return AcademicDepartment.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<AcademicDepartment?> fetchAcademicDepartmentByKey(String key) async {
    final snapshot = await _db
        .collection('academic_department')
        .where('key', isEqualTo: key)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return AcademicDepartment.fromMap(doc.data(), doc.id);
    }
    return null;
  }

  @override
  Future<List<AcademicDepartment>> fetchAllAcademicDepartments() async {
    final snapshot = await _db.collection('academic_department').get();

    return snapshot.docs.map((doc) {
      return AcademicDepartment.fromMap(doc.data(), doc.id);
    }).toList();
  }
}

final academicDepartmentRepoProvider = Provider<AcademicDepartmentRepository>(
  (ref) => AcademicDepartmentRepositoryImpl(),
);