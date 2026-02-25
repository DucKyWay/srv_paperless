import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/academic_department_model.dart';
import '../data/repositories/academic_department_repo.dart';
class AcademicDepartmentService {
  final AcademicDepartmentRepository academicDepartmentRepo;

  AcademicDepartmentService(this.academicDepartmentRepo);

  Future<List<AcademicDepartment>> getAllAcademicDepartments() async {
    return await academicDepartmentRepo.fetchAllAcademicDepartments();
  }
  Future<AcademicDepartment?> getAcademicDepartmentById(String id) async {
    return await academicDepartmentRepo.fetchAcademicDepartmentById(id);
  }
  Future<AcademicDepartment?> getAcademicDepartmentByKey(String key) async {
    return await academicDepartmentRepo.fetchAcademicDepartmentByKey(key);
  }
}

final academicDepartmentServiceProvider = Provider<AcademicDepartmentService>((ref) {
  final repo = ref.watch(academicDepartmentRepoProvider);
  return AcademicDepartmentService(repo);
});