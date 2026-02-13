import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:srv_paperless/data/minio.dart';
import 'package:srv_paperless/data/repositories/user_repo.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileViewModel, AsyncValue<void>>((ref) {
      return UserProfileViewModel(ref);
    });

class UserProfileViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  UserProfileViewModel(this.ref) : super(const AsyncValue.data(null));

  Future<void> updateProfileImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return;

    state = const AsyncValue.loading();

    try {
      final user = ref.read(authProvider).currentUser!;
      final uid = user.id;

      if (user.image.isNotEmpty && user.image != "user.png") {
        await deleteFile(user.image);
      }

      final String filename =
          "profile_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";
      await uploadFile(filename, image.path);

      await ref.read(userRepoProvider).updateProfileImage(uid, filename);
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
      final uid = user.id;

      await ref.read(userRepoProvider).updatePhoneNumber(uid, phone);
      await ref.read(authProvider.notifier).getCurrentUser();

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
