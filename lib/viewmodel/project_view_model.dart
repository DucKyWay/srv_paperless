import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/constants/project_status_enum.dart';
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
        status: isDraft ? ProjectStatus.draft : ProjectStatus.pending,
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
        _refreshProjectLists(result.id);
      }
      return result != null;
    });
  }

  Future<void> updateProject({
    required String id,
    required Project project,
    File? pdfFile,
  }) async {
    try {
      state = const AsyncValue.loading();

      final bool isSuccess = await ref
          .read(projectServiceProvider)
          .updateProject(id, project);

      if (isSuccess && pdfFile != null) {
        await ref
            .read(projectServiceProvider)
            .uploadProjectFile(projectId: id, filePath: pdfFile.path);
      }

      if (isSuccess) {
        _refreshProjectLists(id);
      }

      state = AsyncValue.data(isSuccess);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProjectStatus(String id, ProjectStatus status) async {
    try {
      state = const AsyncValue.loading();

      final bool isSuccess = await ref
          .read(projectServiceProvider)
          .updateProjectStatus(id, status);
      if (isSuccess) {
        _refreshProjectLists(id);
      }

      state = AsyncValue.data(isSuccess);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteProject(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final bool isSuccess = await ref
          .read(projectServiceProvider)
          .deleteProject(id);
      if (isSuccess) {
        _refreshProjectLists(id);
      }
      return isSuccess;
    });
  }

  void _refreshProjectLists(String? projectId) {
    ref.invalidate(allProjectsProvider);
    ref.invalidate(pendingProjectsProvider);
    ref.invalidate(draftProjectsProvider);
    ref.invalidate(approvedProjectsProvider);
    ref.invalidate(startedProjectsProvider);
    ref.invalidate(rejectedProjectsProvider);

    if (projectId != null) {
      ref.invalidate(projectByIdProvider(projectId));
    }
  }
}

class SelectedBudgetYear extends Notifier<String?> {
  @override
  String? build() => null;

  void setYear(String? year) {
    state = year;
  }
}

final selectedBudgetYearProvider =
    NotifierProvider<SelectedBudgetYear, String?>(SelectedBudgetYear.new);

final allProjectsProvider = FutureProvider<List<Project>>((ref) {
  return ref.watch(projectServiceProvider).getProjectAll();
});

final approvedProjectsProvider = FutureProvider<List<Project>>((ref) {
  final selectedYear = ref.watch(selectedBudgetYearProvider);
  return ref
      .watch(projectServiceProvider)
      .getApprovedProjects(budgetYear: selectedYear);
});

final startedProjectsProvider = FutureProvider<List<Project>>((ref) {
  final selectedYear = ref.watch(selectedBudgetYearProvider);
  return ref
      .watch(projectServiceProvider)
      .getStartedProjects(budgetYear: selectedYear);
});

final pendingProjectsProvider = FutureProvider<List<Project>>((ref) {
  final selectedYear = ref.watch(selectedBudgetYearProvider);
  return ref
      .watch(projectServiceProvider)
      .getPendingProjects(budgetYear: selectedYear);
});

final rejectedProjectsProvider = FutureProvider<List<Project>>((ref) {
  final selectedYear = ref.watch(selectedBudgetYearProvider);
  return ref
      .watch(projectServiceProvider)
      .getRejectProjects(budgetYear: selectedYear);
});

final draftProjectsProvider = FutureProvider.family<List<Project>, String>((
  ref,
  userId,
) {
  return ref.watch(projectServiceProvider).getDraftProjectsByUserId(userId);
});

final finishedProjectProvider = FutureProvider<List<Project>>((ref) {
  final selectedYear = ref.watch(selectedBudgetYearProvider);
  return ref
      .watch(projectServiceProvider)
      .getFinishedProjects(budgetYear: selectedYear);
});

final approvedProjectsCount = FutureProvider<int>((ref) {
  final selectedYear = ref.watch(selectedBudgetYearProvider);
  return ref
      .watch(projectServiceProvider)
      .getApprovedProjectsCount(budgetYear: selectedYear);
});

final startedProjectsCount = FutureProvider<int>((ref) {
  final selectedYear = ref.watch(selectedBudgetYearProvider);
  return ref
      .watch(projectServiceProvider)
      .getStartedProjectsCount(budgetYear: selectedYear);
});

final rejectProjectsCount = FutureProvider<int>((ref) {
  final selectedYear = ref.watch(selectedBudgetYearProvider);
  return ref
      .watch(projectServiceProvider)
      .getRejectProjectsCount(budgetYear: selectedYear);
});

final pendingProjectsCount = FutureProvider<int>((ref) {
  final selectedYear = ref.watch(selectedBudgetYearProvider);
  return ref
      .watch(projectServiceProvider)
      .getPendingProjectsCount(budgetYear: selectedYear);
});

final finishedProjectsCount = FutureProvider<int>((ref) {
  final selectedYear = ref.watch(selectedBudgetYearProvider);
  return ref
      .watch(projectServiceProvider)
      .getFinishedProjectsCount(budgetYear: selectedYear);
});

final usedBudgetProvider = FutureProvider<double>((ref) {
  final year = ref.watch(selectedBudgetYearProvider);
  return ref.watch(projectServiceProvider).getTotalBudgetUsed(budgetYear: year);
});

final finishedBudgetProvider = FutureProvider<double>((ref) {
  final year = ref.watch(selectedBudgetYearProvider);
  return ref.watch(projectServiceProvider).getFinishedBudget(budgetYear: year);
});

final projectByIdProvider = FutureProvider.family<Project?, String>((ref, id) {
  return ref.watch(projectServiceProvider).getProjectById(id);
});
