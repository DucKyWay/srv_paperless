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
      final int isSuccess = await ref
          .read(userServiceProvider)
          .updateUser(uid, updatedUser);
      if (isSuccess == 0) {
        _refreshUser();
      }
      return isSuccess;
    } catch (e) {
      debugPrint("Failed to updated User: $e");
      return 1;
    }
  }

  Future<void> updateProfileImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return;

    state = const AsyncValue.loading();

    try {
      final authState = ref.read(authProvider).value;
      final user = authState?.currentUser;

      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }

      await deleteOldUserProfileImages(user.id);

      final String filename =
          "profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      await uploadFile(filename, image.path);

      await ref.read(userServiceProvider).updateProfileImage(user.id, filename);

      await ref.read(authProvider.notifier).refreshUser();

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updatePhoneNumber(String phone) async {
    if (phone.isEmpty) return;

    state = const AsyncValue.loading();

    try {
      final authState = ref.read(authProvider).value;
      final user = authState?.currentUser;

      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }

      await ref.read(userServiceProvider).updatePhoneNumber(user.id, phone);

      await ref.read(authProvider.notifier).refreshUser();

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _refreshUser() {
    ref.invalidate(allUsersProvider);
    ref.invalidate(userByIdProvider);
    ref.invalidate(userByUsernameProvider);
  }
}

final allUsersProvider = FutureProvider<List<User>>((ref) {
  ref.keepAlive();
  return ref.watch(userServiceProvider).getAllUsers();
});

final userByIdProvider = FutureProvider.family<User?, String>((ref, id) {
  ref.keepAlive();
  return ref.watch(userServiceProvider).getUserById(id);
});

final userByUsernameProvider = FutureProvider.family<User?, String>((ref, username) {
  ref.keepAlive();
  return ref.watch(userServiceProvider).getUserByUsername(username);
});
