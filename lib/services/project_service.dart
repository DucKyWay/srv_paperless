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

  Future<List<Project>> getApprovedProjects() async {
    return await projectRepo.fetchProjectsByStatus('approved');
  }

  Future<List<Project>> getRejectProjects() async {
    return await projectRepo.fetchProjectsByStatus('reject');
  }

  Future<List<Project>> getDraftProjectsbyUserId(String id) async {
    return await projectRepo.fetchProjectDraftByUserId(id);
  }

  Future<bool> createProject(Project project) async {
    final result = await projectRepo.create(project);
    return result == 0; 
  }

  Future<bool> updateProject(String id, Project project) async {
    final result = await projectRepo.update(id, project);
    return result == 0;
  }

  Future<bool> deleteProject(String id) async {
    final result = await projectRepo.delete(id);
    return result == 0;
  }
}

final projectServiceProvider = Provider<ProjectService>((ref) {
  final repo = ref.watch(projectRepoProvider);
  return ProjectService(repo);
});