import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:srv_paperless/data/minio.dart';
import 'package:srv_paperless/data/model/project_location_model.dart';
import 'package:srv_paperless/data/repositories/project_location_repo.dart';

final projectLocationProvider =
    AsyncNotifierProvider<ProjectLocationViewModel, bool>(
  ProjectLocationViewModel.new,
);

class ProjectLocationViewModel extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() {
    return false;
  }

  Future<void> createLocationWithImage({
    required ProjectLocation projectLocation,
    required XFile? imageFile,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      String? uploadedFileName = projectLocation.locationImagePath;

      if (imageFile != null) {
        final fileName =
            "loc_${projectLocation.requestId}_${DateTime.now().millisecondsSinceEpoch}.jpg";
        await uploadFile(fileName, imageFile.path);
        uploadedFileName = fileName;
      }

      final updatedLocation = projectLocation.copyWith(
        locationImagePath: uploadedFileName,
      );

      final repository = ref.read(projectLocationRepoProvider);
      final result = await repository.create(updatedLocation);

      if (result == 1) {
        ref.invalidate(projectLocationsProvider(projectLocation.requestId!));
      }
      return result == 1;
    });
  }

  // เพิ่มฟังก์ชันอัปเดตพร้อมรูปภาพ
  Future<void> updateLocationWithImage({
    required String id,
    required ProjectLocation projectLocation,
    required XFile? imageFile,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      String? uploadedFileName = projectLocation.locationImagePath;

      if (imageFile != null) {
        final fileName =
            "loc_${projectLocation.requestId}_${DateTime.now().millisecondsSinceEpoch}.jpg";
        await uploadFile(fileName, imageFile.path);
        uploadedFileName = fileName;
      }

      final updatedLocation = projectLocation.copyWith(
        locationImagePath: uploadedFileName,
      );

      final repository = ref.read(projectLocationRepoProvider);
      final result = await repository.update(id, updatedLocation);

      if (result == 1) {
        ref.invalidate(projectLocationsProvider(projectLocation.requestId!));
      }
      return result == 1;
    });
  }

  Future<void> updateLocation({
    required String id,
    required ProjectLocation projectLocation,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(projectLocationRepoProvider);
      final result = await repository.update(id, projectLocation);
      if (result == 1) {
        ref.invalidate(projectLocationsProvider(projectLocation.requestId!));
      }
      return result == 1;
    });
  }

  Future<void> deleteLocation(String id, String requestId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(projectLocationRepoProvider);
      final result = await repository.delete(id);
      if (result == 1) {
        ref.invalidate(projectLocationsProvider(requestId));
      }
      return result == 1;
    });
  }
}

final projectLocationsProvider =
    FutureProvider.family<List<ProjectLocation>, String>((ref, id) {
  return ref.watch(projectLocationRepoProvider).fetchAllProjectLocationById(id);
});
