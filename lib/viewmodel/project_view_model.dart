import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/project_model.dart';
import 'package:srv_paperless/services/project_service.dart';

final projectProvider = AsyncNotifierProvider<ProjectViewModel, bool>(
  ProjectViewModel.new,
);

class ProjectViewModel extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() {
    return false;
  }

  Future<void> saveProject({
    required Project project,
    required bool isDraft,
    required File? pdfFile,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final projectWithStatus = project.copyWith(
        status: isDraft ? 'draft' : 'pending',
      );

      final result = await ref
          .read(projectServiceProvider)
          .createProject(projectWithStatus);

      if (result != null && pdfFile != null) {
        await ref
            .read(projectServiceProvider)
            .uploadProjectFile(projectId: result.id, filePath: pdfFile.path);
      }
      if (result != null) {
      _refreshProjectLists(); 
    }
      return result != null;
    });
    
  }

  Future<void> updateProject({
    required String id, 
    required Project project
    }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final bool isSuccess = await ref.read(projectServiceProvider).updateProject(id, project);
      if (isSuccess) {
      _refreshProjectLists(); 
    }
      return isSuccess; 
    });
  }

  Future<void> deleteProject(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final bool isSuccess = await ref.read(projectServiceProvider).deleteProject(id);
      if (isSuccess) {
      _refreshProjectLists(); 
    }
      return isSuccess; 
    });
  }
  void _refreshProjectLists() {
  ref.invalidate(allProjectsProvider);
  ref.invalidate(pendingProjectsProvider);
  ref.invalidate(draftProjectsProvider); // ถ้าใช้ family อาจจะต้องระบุ ID หรือล้างทั้งหมด
  ref.invalidate(approvedProjectsProvider);
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
