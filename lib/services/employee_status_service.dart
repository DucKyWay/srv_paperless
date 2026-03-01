import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/employee_status_model.dart';
import '../data/repositories/employee_status_repo.dart';

class EmployeeStatusService {
  final EmployeeStatusRepository employeeStatusRepo;

  EmployeeStatusService(this.employeeStatusRepo);

  Future<List<EmployeeStatus>> fetchAllEmployeeStatus() async {
    return await employeeStatusRepo.fetchAllEmployeeStatus();
  }

  Future<EmployeeStatus?> fetchEmployeeStatusById(String id) async {
    return await employeeStatusRepo.fetchEmployeeStatusById(id);
  }

  Future<EmployeeStatus?> fetchEmployeeStatusByKey(String key) async {
    return await employeeStatusRepo.fetchEmployeeStatusByKey(key);
  }

  Future<int> createEmployeeStatus(EmployeeStatus es) async {
    return await employeeStatusRepo.create(es);
  }

  Future<int> updateEmployeeStatus(String uid, EmployeeStatus es) async {
    return await employeeStatusRepo.update(uid, es);
  }

  Future<int> deleteEmployeeStatus(String uid) async {
    return await employeeStatusRepo.delete(uid);
  }
}

final employeeStatusServiceProvider = Provider<EmployeeStatusService>((ref) {
  final repo = ref.watch(employeeStatusRepoProvider);
  return EmployeeStatusService(repo);
});
