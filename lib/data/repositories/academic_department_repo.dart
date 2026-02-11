import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/db_manager.dart';
import 'package:srv_paperless/data/model/academic_department_model.dart';

abstract class AcademicDepartmentRepository {
  Future<List<AcademicDepartment>> fetchAllAcademicDepartments();
  Future<AcademicDepartment?> fetchAcademicDepartmentById(int id);
  Future<AcademicDepartment?> fetchAcademicDepartmentByKey(String key);
}

class AcademicDepartmentRepositoryImpl implements AcademicDepartmentRepository {
  final DbManager db;
  final Ref ref;
  AcademicDepartmentRepositoryImpl(this.db, this.ref);

  @override
  Future<AcademicDepartment?> fetchAcademicDepartmentById(int id) async {
    final maps = await db.query(
      "SELECT a_department_id, a_department_key, a_department_label FROM academic_department WHERE a_department_id = ?",
      [id],
    );

    if (maps.isNotEmpty) {
      return AcademicDepartment.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<AcademicDepartment?> fetchAcademicDepartmentByKey(String key) async {
    final maps = await db.query(
      "SELECT a_department_id, a_department_key, a_department_label FROM academic_department WHERE a_department_key = ?",
      [key],
    );

    if (maps.isNotEmpty) {
      return AcademicDepartment.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<AcademicDepartment>> fetchAllAcademicDepartments() async {
    final List<Map<String, dynamic>> maps = await db.query(
      'academic_department',
    );

    return List.generate(maps.length, (i) {
      return AcademicDepartment.fromMap(maps[i]);
    });
  }
}

final academicDepartmentRepoProvider = Provider<AcademicDepartmentRepository>((
  ref,
) {
  final db = DbManager();
  return AcademicDepartmentRepositoryImpl(db, ref);
});

// ===== Provider =====

final getAllDepartments = FutureProvider<List<AcademicDepartment>>((ref) async {
  final repo = ref.watch(academicDepartmentRepoProvider);
  return await repo.fetchAllAcademicDepartments();
});

final getDepartmentByKey = FutureProvider.family<AcademicDepartment?, String>((ref, key) async {
  final repo = ref.watch(academicDepartmentRepoProvider);
  return await repo.fetchAcademicDepartmentByKey(key);
});