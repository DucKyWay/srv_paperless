import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/db_manager.dart';
import 'package:srv_paperless/data/model/academic_department_model.dart';

abstract class AcademicDepartmentRepository {
  Future<List<AcademicDepartment>> getAllAcademicDepartments();
  Future<AcademicDepartment?> getAcademicDepartmentById(int id);
  Future<AcademicDepartment?> getAcademicDepartmentByKey(String key);
  Future<AcademicDepartment?> getAcademicDepartmentByLabel(String label);
}

class AcademicDepartmentRepositoryImpl implements AcademicDepartmentRepository {
  final DbManager db;
  final Ref ref;
  AcademicDepartmentRepositoryImpl(this.db, this.ref);

  @override
  Future<AcademicDepartment?> getAcademicDepartmentById(int id) async {
    final maps = await db.query(
      "SELECT * FROM academic_department WHERE a_department_id = ?",
      [id]
    );

    if (maps.isNotEmpty) {
      return AcademicDepartment.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<AcademicDepartment?> getAcademicDepartmentByKey(String key) async {
    final maps = await db.query(
      "SELECT * FROM academic_department WHERE a_department_key = ?",
      [key]
    );

    if (maps.isNotEmpty) {
      return AcademicDepartment.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<AcademicDepartment?> getAcademicDepartmentByLabel(String label) async {
    final maps = await db.query(
      "SELECT * FROM academic_department WHERE a_department_label = ?",
      [label]
    );

    if (maps.isNotEmpty) {
      return AcademicDepartment.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<AcademicDepartment>> getAllAcademicDepartments() async {
    final List<Map<String, dynamic>> maps = await db.query('academic_department');
    
    return List.generate(maps.length, (i) {
      return AcademicDepartment.fromMap(maps[i]);
    });
  }
}

final academicDepartmentRepoProvider = Provider<AcademicDepartmentRepository>((ref) {
  final db = DbManager();
  return AcademicDepartmentRepositoryImpl(db, ref);
});