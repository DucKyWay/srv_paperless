import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/employee_status_model.dart';
import '../data/repositories/employee_status_repo.dart';

class EmployeeStatusService {
  final EmployeeStatusRepository employeeStatusRepo;

  EmployeeStatusService(this.employeeStatusRepo);

  Future<List<EmployeeStatus>> getAllEmployeeStatus() async {
    return await employeeStatusRepo.fetchAllEmployeeStatus();
  }
  Future<EmployeeStatus?> getEmployeeStatusById(String id) async {
    return await employeeStatusRepo.fetchEmployeeStatusById(id);
  }
  Future<EmployeeStatus?> getEmployeeStatusByKey(String key) async {
    return await employeeStatusRepo.fetchEmployeeStatusByKey(key);
  }
}

final employeeStatusServiceProvider = Provider<EmployeeStatusService>((ref) {
  final repo = ref.watch(employeeStatusRepoProvider);
  return EmployeeStatusService(repo);
});