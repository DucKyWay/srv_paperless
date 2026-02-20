import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/employee_status_model.dart';
import '../services/employee_status_service.dart';

final employeeStatusProvider =
    AsyncNotifierProvider<EmployeeStatusViewModel, void>(
      EmployeeStatusViewModel.new,
    );

class EmployeeStatusViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}
}

final allEmployeeStatus = FutureProvider<List<EmployeeStatus>>((ref) {
  return ref.watch(employeeStatusServiceProvider).getAllEmployeeStatus();
});

final employeeStatusById = FutureProvider.family<EmployeeStatus?, String>((
  ref,
  id,
) {
  return ref.watch(employeeStatusServiceProvider).getEmployeeStatusById(id);
});

final employeeStatusByKey = FutureProvider.family<EmployeeStatus?, String>((
  ref,
  key,
) {
  return ref.watch(employeeStatusServiceProvider).getEmployeeStatusByKey(key);
});
