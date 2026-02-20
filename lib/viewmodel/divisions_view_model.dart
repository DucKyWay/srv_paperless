import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/divisions_model.dart';
import 'package:srv_paperless/services/divisions_service.dart';

final divisionsProvider = AsyncNotifierProvider<DivisionsViewModel, void>(
  DivisionsViewModel.new
);

class DivisionsViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}
}

final allDivisions = FutureProvider<List<Divisions>>((ref) {
  return ref.watch(divisionsServiceProvider).getAllDivisions();
});

final divisionsById = FutureProvider.family<Divisions?, String>((ref, id) {
  return ref.watch(divisionsServiceProvider).getDivisionById(id);
});

final divisionsByKey = FutureProvider.family<Divisions?, String>((ref, key) {
  return ref.watch(divisionsServiceProvider).getDivisionByKey(key);
});