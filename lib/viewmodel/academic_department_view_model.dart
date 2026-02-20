import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/model/academic_department_model.dart';
import '../services/academic_department_service.dart';

final academicDepartmentProvider = StateNotifierProvider<AcademicDepartmentViewModel, AsyncValue<void>>((ref) {
  return AcademicDepartmentViewModel(ref);
});

class AcademicDepartmentViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  AcademicDepartmentViewModel(this.ref) : super (const AsyncValue.data(null));
}

final allAcademicDepartment = FutureProvider<List<AcademicDepartment>>((ref) {
  return ref.watch(academicDepartmentServiceProvider).getAllAcademicDepartments();
});

final academicDepartmentById = FutureProvider.family<AcademicDepartment?, String>((ref, id) {
  return ref.watch(academicDepartmentServiceProvider).getAcademicDepartmentById(id);
});

final academicDepartmentByKey = FutureProvider.family<AcademicDepartment?, String>((ref, key) {
  return ref.watch(academicDepartmentServiceProvider).getAcademicDepartmentByKey(key);
});