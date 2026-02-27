import 'dart:async';

import 'package:flutter/material.dart';
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

  Future<EmployeeStatus?> createEmployeeStatus(String key, String label) async {
    final employeeStatus = EmployeeStatus(key: key, label: label);
    int success = await ref
        .read(employeeStatusServiceProvider)
        .createEmployeeStatus(employeeStatus);

    if (success == 0) {
      debugPrint("Create Employee Status");
      return ref
          .read(employeeStatusServiceProvider)
          .getEmployeeStatusByKey(key);
    } else {
      debugPrint("Failed to create Employee Status");
      return null;
    }
  }

  Future<void> updateEmployeeStatus(String id, String key, String label) async {
    if (id.isEmpty || key.isEmpty || label.isEmpty) {
      debugPrint("Parameter cannot empty");
      return;
    } else {
      final employeeStatus = EmployeeStatus(key: key, label: label);
      await ref
          .read(employeeStatusServiceProvider)
          .updateEmployeeStatus(id, employeeStatus);
    }
  }

  Future<void> deleteEmployeeStatus(String id) async {
    if (id.isEmpty) {
      debugPrint("ID cannot empty");
    } else {
      await ref.read(employeeStatusServiceProvider).deleteEmployeeStatus(id);
    }
  }
}

final allEmployeeStatus = FutureProvider<List<EmployeeStatus>>((ref) {
  ref.keepAlive();
  return ref.watch(employeeStatusServiceProvider).getAllEmployeeStatus();
});

final employeeStatusById = FutureProvider.family<EmployeeStatus?, String>((
  ref,
  id,
) {
  ref.keepAlive();
  return ref.watch(employeeStatusServiceProvider).getEmployeeStatusById(id);
});

final employeeStatusByKey = FutureProvider.family<EmployeeStatus?, String>((
  ref,
  key,
) {
  ref.keepAlive();
  return ref.watch(employeeStatusServiceProvider).getEmployeeStatusByKey(key);
});
