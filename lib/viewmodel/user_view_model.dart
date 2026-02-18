import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:srv_paperless/data/minio.dart';
import 'package:srv_paperless/data/repositories/user_repo.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';

import '../data/model/user_model.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileViewModel, AsyncValue<void>>((ref) {
      return UserProfileViewModel(ref);
    });

class UserProfileViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  UserProfileViewModel(this.ref) : super(const AsyncValue.data(null));

  Future<List<User>> getAllUsers() async {
    try {
      return await ref.read(userRepoProvider).fetchAllUsers();
    } catch (e) {
      if (kDebugMode) print("Failed to get Users: $e");
      return [];
    }
  }

  Future<User?> getUserById(String id) async {
    if (id.isEmpty) return null;

    try {
      return await ref.read(userRepoProvider).fetchUserById(id);
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserByUsername(String username) async {
    if (username.isEmpty) return null;

    try {
      return await ref.read(userRepoProvider).fetchUserByUsername(username);
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

      await ref.read(userRepoProvider).updateProfileImage(user.id, filename);
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

      await ref.read(userRepoProvider).updatePhoneNumber(user.id, phone);
      await ref.read(authProvider.notifier).getCurrentUser();

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
