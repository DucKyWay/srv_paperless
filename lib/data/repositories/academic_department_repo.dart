import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/academic_department_model.dart';

abstract class AcademicDepartmentRepository {
  Future<List<AcademicDepartment>> fetchAllAcademicDepartments();
  Future<AcademicDepartment?> fetchAcademicDepartmentById(String id);
  Future<AcademicDepartment?> fetchAcademicDepartmentByKey(String key);
  Future<int> create(AcademicDepartment ad);
  Future<int> update(String uid, AcademicDepartment newAd);
  Future<int> delete(String uid);
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
    final snapshot =
        await _db
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

  @override
  Future<int> create(AcademicDepartment ad) async {
    try {
      final doc = _db.collection('academic_department').doc();
      final newAd = ad.copyWith(id: doc.id);
      await doc.set(newAd.toMap());
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> delete(String uid) async {
    try {
      final ad = await fetchAcademicDepartmentById(uid);

      if(ad != null) {
        await _db.collection('academic_department').doc(uid).delete();
        return 0;
      } else {
        return 1;
      }
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> update(String uid, AcademicDepartment newAd) async {
    try {
      await _db.collection('academic_department').doc(uid).update(newAd.toMap());
      return 0;
    } catch (e) {
      return 1;
    }
  }
}

final academicDepartmentRepoProvider = Provider<AcademicDepartmentRepository>(
  (ref) => AcademicDepartmentRepositoryImpl(),
);
