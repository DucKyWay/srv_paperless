import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/db_manager.dart';
import 'package:srv_paperless/data/model/employee_status_model.dart';

abstract class EmployeeStatusRepository {
  Future<List<EmployeeStatus>> getAllEmployeeStatus();
  Future<EmployeeStatus?> getEmployeeStatusById(int id);
  Future<EmployeeStatus?> getEmployeeStatusByKey(String key);
  Future<EmployeeStatus?> getEmployeeStatusByLabel(String label);
}

class EmployeeStatusRepositoryImpl implements EmployeeStatusRepository {
  final DbManager db;
  final Ref ref;
  EmployeeStatusRepositoryImpl(this.db, this.ref);

  @override
  Future<EmployeeStatus?> getEmployeeStatusById(int id) async {
    final maps = await db.query(
      "SELECT * FROM academic_department WHERE a_department_id = ?",
      [id]
    );

    if (maps.isNotEmpty) {
      return EmployeeStatus.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<EmployeeStatus?> getEmployeeStatusByKey(String key) async {
    final maps = await db.query(
      "SELECT * FROM academic_department WHERE a_department_key = ?",
      [key]
    );

    if (maps.isNotEmpty) {
      return EmployeeStatus.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<EmployeeStatus?> getEmployeeStatusByLabel(String label) async {
    final maps = await db.query(
      "SELECT * FROM academic_department WHERE a_department_label = ?",
      [label]
    );

    if (maps.isNotEmpty) {
      return EmployeeStatus.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<EmployeeStatus>> getAllEmployeeStatus() async {
    final List<Map<String, dynamic>> maps = await db.query('academic_department');
    
    return List.generate(maps.length, (i) {
      return EmployeeStatus.fromMap(maps[i]);
    });
  }
}

final employeeStatusRepoProvider = Provider<EmployeeStatusRepository>((ref) {
  final db = DbManager();
  return EmployeeStatusRepositoryImpl(db, ref);
});