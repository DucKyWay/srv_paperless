import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/constants/project_status_enum.dart';
import 'package:srv_paperless/data/model/project_model.dart';
import 'package:srv_paperless/services/project_service.dart';

final projectProvider = AsyncNotifierProvider<ProjectViewModel, void>(
  ProjectViewModel.new,
);

class ProjectViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> saveProject({
    required Project project,
    required bool isDraft,
    required File? pdfFile,
  }) async {
    try {
      state = const AsyncValue.loading();
      final projectWithStatus = project.copyWith(
        status: isDraft ? ProjectStatus.draft : ProjectStatus.pending,
      );
      final result = await ref
          .read(projectServiceProvider)
          .createProject(projectWithStatus);
      state = AsyncValue.data(result);

      if (result != null && pdfFile != null) {
        final String projectId = result.id;
        final filename = await ref
            .read(projectServiceProvider)
            .uploadProjectFile(projectId: projectId, filePath: pdfFile.path);
      }

      ref.invalidate(allProjectsProvider);
      ref.invalidate(draftProjectsProvider);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      if (kDebugMode) print(e);
    }
  }

  Future<void> updateProject(String id, Project project) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(projectServiceProvider).updateProject(id, project),
    );
  }

  Future<void> deleteProject(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(projectServiceProvider).deleteProject(id),
    );
  }
}

final allProjectsProvider = FutureProvider<List<Project>>((ref) {
  return ref.watch(projectServiceProvider).getProjectAll();
});

final approvedProjectsProvider = FutureProvider<List<Project>>((ref) {
  return ref.watch(projectServiceProvider).getApprovedProjects();
});
final pendingProjectsProvider = FutureProvider<List<Project>>((ref) {
  return ref.watch(projectServiceProvider).getPendingProjects();
});

final draftProjectsProvider = FutureProvider.family<List<Project>, String>((
  ref,
  userId,
) {
  return ref.watch(projectServiceProvider).getDraftProjectsByUserId(userId);
});

final projectByIdProvider = FutureProvider.family<Project?, String>((ref, id) {
  return ref.watch(projectServiceProvider).getProjectById(id);
});
