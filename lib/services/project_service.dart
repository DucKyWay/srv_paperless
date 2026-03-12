import 'package:flutter/cupertino.dart';
import 'package:srv_paperless/core/constants/project_status_enum.dart';
import 'package:srv_paperless/data/minio.dart';
import 'package:srv_paperless/data/repositories/project_repo.dart';
import 'package:srv_paperless/data/model/project_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectService {
  final ProjectRepository projectRepo;

  ProjectService(this.projectRepo);

  Future<List<Project>> getProjectAll() async {
    return await projectRepo.fetchAllProjects();
  }

  Future<Project?> getProjectById(String id) async {
    return await projectRepo.fetchProjectById(id);
  }

  Future<List<Project>> getApprovedProjects({String? budgetYear}) async {
    return await projectRepo.fetchProjectsByStatus(
      ProjectStatus.approve.name,
      budgetYear: budgetYear,
    );
  }

  Future<List<Project>> getStartedProjects({String? budgetYear}) async {
    return await projectRepo.fetchProjectsByStatus(
      ProjectStatus.started.name,
      budgetYear: budgetYear,
    );
  }

  Future<List<Project>> getRejectProjects({String? budgetYear}) async {
    return await projectRepo.fetchProjectsByStatus(
      ProjectStatus.rejected.name,
      budgetYear: budgetYear,
    );
  }

  Future<List<Project>> getPendingProjects({String? budgetYear}) async {
    return await projectRepo.fetchProjectsByStatus(
      ProjectStatus.pending.name,
      budgetYear: budgetYear,
    );
  }

  Future<List<Project>> getFinishedProjects({String? budgetYear}) async {
    return await projectRepo.fetchProjectsByStatus(
      ProjectStatus.finished.name,
      budgetYear: budgetYear,
    );
  }

  Future<int> getApprovedProjectsCount({String? budgetYear}) async {
    return await projectRepo
        .fetchProjectsByStatus(
          ProjectStatus.approve.name,
          budgetYear: budgetYear,
        )
        .then((value) => value.length);
  }

  Future<int> getStartedProjectsCount({String? budgetYear}) async {
    return await projectRepo
        .fetchProjectsByStatus(
          ProjectStatus.started.name,
          budgetYear: budgetYear,
        )
        .then((value) => value.length);
  }

  Future<int> getRejectProjectsCount({String? budgetYear}) async {
    return await projectRepo
        .fetchProjectsByStatus(
          ProjectStatus.rejected.name,
          budgetYear: budgetYear,
        )
        .then((value) => value.length);
  }

  Future<int> getPendingProjectsCount({String? budgetYear}) async {
    return await projectRepo
        .fetchProjectsByStatus(
          ProjectStatus.pending.name,
          budgetYear: budgetYear,
        )
        .then((value) => value.length);
  }

  Future<int> getFinishedProjectsCount({String? budgetYear}) async {
    return await projectRepo
        .fetchProjectsByStatus(
          ProjectStatus.finished.name,
          budgetYear: budgetYear,
        )
        .then((value) => value.length);
  }

  Future<List<Project>> getDraftProjectsByUserId(String id) async {
    return await projectRepo.fetchProjectDraftByUserId(id);
  }

  Future<double> getTotalBudgetUsed({String? budgetYear}) async {
    final projects = await projectRepo.fetchProjectsByStatus(
      ProjectStatus.started.name,
      budgetYear: budgetYear,
    );

    double total = 0;

    for (final project in projects) {
      total += await project.budget ?? 0;
    }

    return total;
  }

  Future<double> getFinishedBudget({String? budgetYear}) async {
    final projects = await projectRepo.fetchProjectsByStatus(
      ProjectStatus.finished.name,
      budgetYear: budgetYear,
    );

    double total = 0;

    for (final project in projects) {
      total += project.budget ?? 0;
    }

    return total;
  }

  Future<Project?> createProject(Project project) async {
    final result = await projectRepo.create(project);
    return result;
  }

  Future<bool> updateProject(String id, Project project) async {
    final result = await projectRepo.update(id, project);
    return result == 0;
  }

  Future<bool> updateProjectStatus(String id, ProjectStatus status) async {
    final project = await projectRepo.fetchProjectById(id);
    if (project != null) {
      project.status = status;
      final result = await projectRepo.update(id, project);
      return result == 0;
    }

    return false;
  }

  Future<bool> deleteProject(String id) async {
    final result = await projectRepo.delete(id);
    return result == 0;
  }

  Future<String?> uploadProjectFile({
    required String projectId,
    required String filePath,
  }) async {
    try {
      final fileName =
          "project_${projectId}_${DateTime.now().millisecondsSinceEpoch}.pdf";
      uploadFile(fileName, filePath);

      final result = await projectRepo.updateProjectFile(projectId, fileName);
      debugPrint("Success to upload: $fileName");
      return result == 0 ? fileName : null;
    } catch (e) {
      debugPrint("Upload failed: $e");
      return null;
    }
  }
}

final projectServiceProvider = Provider<ProjectService>((ref) {
  final repo = ref.watch(projectRepoProvider);
  return ProjectService(repo);
});
