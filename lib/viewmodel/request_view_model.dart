import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final requestProvider = StateNotifierProvider<RequestViewModel, AsyncValue<void>>((ref) {
  return RequestViewModel(ref);
});

class RequestViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  RequestViewModel(this.ref) : super (const AsyncValue.data(null));
}