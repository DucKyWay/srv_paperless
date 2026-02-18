import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final projectProvider = StateNotifierProvider<ProjectViewModel, AsyncValue<void>>((ref) {
  return ProjectViewModel(ref);
});

class ProjectViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  ProjectViewModel(this.ref) : super (const AsyncValue.data(null));
}