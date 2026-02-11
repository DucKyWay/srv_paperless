import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/db_manager.dart';
import 'package:srv_paperless/data/model/employee_status_model.dart';

abstract class EmployeeStatusRepository {
  Future<List<EmployeeStatus>> fetchAllEmployeeStatus();
  Future<EmployeeStatus?> fetchEmployeeStatusById(int id);
  Future<EmployeeStatus?> fetchEmployeeStatusByKey(String key);
}

class EmployeeStatusRepositoryImpl implements EmployeeStatusRepository {
  final DbManager db;
  final Ref ref;
  EmployeeStatusRepositoryImpl(this.db, this.ref);

  @override
  Future<EmployeeStatus?> fetchEmployeeStatusById(int id) async {
    final maps = await db.query(
      "SELECT e_status_id, e_status_key, e_status_label FROM employee_status WHERE e_status_id = ?",
      [id]
    );

    if (maps.isNotEmpty) {
      return EmployeeStatus.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<EmployeeStatus?> fetchEmployeeStatusByKey(String key) async {
    final maps = await db.query(
      "SELECT e_status_id, e_status_key, e_status_label FROM employee_status WHERE e_status_key = ?",
      [key]
    );

    if (maps.isNotEmpty) {
      return EmployeeStatus.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<EmployeeStatus>> fetchAllEmployeeStatus() async {
    final List<Map<String, dynamic>> maps = await db.query('employee_status');
    
    return List.generate(maps.length, (i) {
      return EmployeeStatus.fromMap(maps[i]);
    });
  }
}

final employeeStatusRepoProvider = Provider<EmployeeStatusRepository>((ref) {
  final db = DbManager();
  return EmployeeStatusRepositoryImpl(db, ref);
});


// ===== Provider =====

final getAllEmployeeStatus = FutureProvider<List<EmployeeStatus>>((ref) async {
  final repo = ref.watch(employeeStatusRepoProvider);
  return await repo.fetchAllEmployeeStatus();
});

final getEmployeeStatusByKey = FutureProvider.family<EmployeeStatus?, String>((ref, key) async {
  final repo = ref.watch(employeeStatusRepoProvider);
  return await repo.fetchEmployeeStatusByKey(key);
});
