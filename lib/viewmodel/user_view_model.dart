import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:srv_paperless/data/minio.dart';
import 'package:srv_paperless/services/user_service.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';

import '../data/model/user_model.dart';

final userProvider = AsyncNotifierProvider<UserProfileViewModel, void>(
  UserProfileViewModel.new,
);

class UserProfileViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<int> updateUser(String uid, User updatedUser) async {
    try {
      return await ref.read(userServiceProvider).updateUser(uid, updatedUser);
    } catch (e) {
      debugPrint("Failed to updated User: $e");
      return 1;
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      return await ref.read(userServiceProvider).getAllUsers();
    } catch (e) {
      if (kDebugMode) print("Failed to get Users: $e");
      return [];
    }
  }

  Future<User?> getUserById(String id) async {
    if (id.isEmpty) return null;

    try {
      return await ref.read(userServiceProvider).getUserById(id);
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserByUsername(String username) async {
    if (username.isEmpty) return null;

    try {
      return await ref.read(userServiceProvider).getUserByUsername(username);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfileImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return;

    state = const AsyncValue.loading();

    try {
      final user = ref.read(authProvider).currentUser!;

      await deleteOldUserProfileImages(user.id);

      final String filename =
          "profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";
      await uploadFile(filename, image.path);

      await ref.read(userServiceProvider).updateProfileImage(user.id, filename);
      await ref.read(authProvider.notifier).getCurrentUser();

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updatePhoneNumber(String phone) async {
    if (phone.isEmpty) return;

    state = const AsyncValue.loading();
    try {
      final user = ref.read(authProvider).currentUser!;

      await ref.read(userServiceProvider).updatePhoneNumber(user.id, phone);
      await ref.read(authProvider.notifier).getCurrentUser();

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final allUsersProvider = FutureProvider<List<User>>((ref) {
  return ref.watch(userServiceProvider).getAllUsers();
});

final userByIdProvider = FutureProvider.family<User?, String>((ref, id) {
  return ref.watch(userServiceProvider).getUserById(id);
});
