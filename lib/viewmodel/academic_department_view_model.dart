import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/academic_department_model.dart';
import '../services/academic_department_service.dart';

final academicDepartmentProvider = AsyncNotifierProvider<AcademicDepartmentViewModel, void>(
  AcademicDepartmentViewModel.new
);

class AcademicDepartmentViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}
}

final allAcademicDepartment = FutureProvider<List<AcademicDepartment>>((ref) {
  ref.keepAlive();
  return ref.watch(academicDepartmentServiceProvider).getAllAcademicDepartments();
});

final academicDepartmentById = FutureProvider.family<AcademicDepartment?, String>((ref, id) {
  ref.keepAlive();
  return ref.watch(academicDepartmentServiceProvider).getAcademicDepartmentById(id);
});

final academicDepartmentByKey = FutureProvider.family<AcademicDepartment?, String>((ref, key) {
  ref.keepAlive();
  return ref.watch(academicDepartmentServiceProvider).getAcademicDepartmentByKey(key);
});