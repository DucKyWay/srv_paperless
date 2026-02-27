import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/academic_department_model.dart';
import '../services/academic_department_service.dart';

final academicDepartmentProvider =
    AsyncNotifierProvider<AcademicDepartmentViewModel, void>(
      AcademicDepartmentViewModel.new,
    );

class AcademicDepartmentViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<AcademicDepartment?> createAcademicDepartment(
    String key,
    String label,
  ) async {
    final academicDepartment = AcademicDepartment(key: key, label: label);
    int success = await ref
        .read(academicDepartmentServiceProvider)
        .createAcademicDepartment(academicDepartment);

    if (success == 0) {
      debugPrint("Create Academic Department");
      return ref
          .read(academicDepartmentServiceProvider)
          .getAcademicDepartmentByKey(key);
    } else {
      debugPrint("Failed to create academic department");
      return null;
    }
  }

  Future<void> updateAcademicDepartment(
    String id,
    String key,
    String label,
  ) async {
    if (id.isEmpty || key.isEmpty || label.isEmpty) {
      debugPrint("Parameter cannot empty");
      return;
    } else {
      final academicDepartment = AcademicDepartment(key: key, label: label);
      await ref
          .read(academicDepartmentServiceProvider)
          .updateAcademicDepartment(id, academicDepartment);
    }
  }

  Future<void> deleteAcademicDepartment(String id) async {
    if (id.isEmpty) {
      debugPrint("ID cannot empty");
    } else {
      await ref
          .read(academicDepartmentServiceProvider)
          .deleteAcademicDepartment(id);
    }
  }
}

final allAcademicDepartment = FutureProvider<List<AcademicDepartment>>((ref) {
  ref.keepAlive();
  return ref
      .watch(academicDepartmentServiceProvider)
      .getAllAcademicDepartments();
});

final academicDepartmentById =
    FutureProvider.family<AcademicDepartment?, String>((ref, id) {
      ref.keepAlive();
      return ref
          .watch(academicDepartmentServiceProvider)
          .getAcademicDepartmentById(id);
    });

final academicDepartmentByKey =
    FutureProvider.family<AcademicDepartment?, String>((ref, key) {
      ref.keepAlive();
      return ref
          .watch(academicDepartmentServiceProvider)
          .getAcademicDepartmentByKey(key);
    });
