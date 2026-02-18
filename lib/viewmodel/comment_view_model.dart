import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final commentProvider = StateNotifierProvider<CommentViewModel, AsyncValue>((ref) {
  return CommentViewModel(ref);
});

class CommentViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  CommentViewModel(this.ref) : super (const AsyncValue.data(null));
}