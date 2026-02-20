import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/model/academic_department_model.dart';
import '../data/model/employee_status_model.dart';
import '../services/academic_department_service.dart';
import '../services/employee_status_service.dart';

final employeeStatusProvider = StateNotifierProvider<EmployeeStatusViewModel, AsyncValue<void>>((ref) {
  return EmployeeStatusViewModel(ref);
});

class EmployeeStatusViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  EmployeeStatusViewModel(this.ref) : super (const AsyncValue.data(null));
}

final allEmployeeStatus = FutureProvider<List<EmployeeStatus>>((ref) {
  return ref.watch(employeeStatusServiceProvider).getAllEmployeeStatus();
});

final employeeStatusById = FutureProvider.family<EmployeeStatus?, String>((ref, id) {
  return ref.watch(employeeStatusServiceProvider).getEmployeeStatusById(id);
});

final employeeStatusByKey = FutureProvider.family<EmployeeStatus?, String>((ref, key) {
  return ref.watch(employeeStatusServiceProvider).getEmployeeStatusByKey(key);
});