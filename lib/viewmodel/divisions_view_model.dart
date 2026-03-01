import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/divisions_model.dart';
import 'package:srv_paperless/services/divisions_service.dart';

final divisionsProvider = AsyncNotifierProvider<DivisionsViewModel, void>(
  DivisionsViewModel.new,
);

class DivisionsViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Divisions?> createDivisions(String key, String label) async {
    final division = Divisions(key: key, label: label);
    int success = await ref
        .read(divisionsServiceProvider)
        .createDivisions(division);

    if (success == 0) {
      debugPrint("Create Academic Department");
      _refreshDivisions();
      return ref.read(divisionsServiceProvider).fetchDivisionByKey(key);
    } else {
      debugPrint("Failed to create academic department");
      return null;
    }
  }

  Future<void> updateDivisions(String id, String key, String label) async {
    if (id.isEmpty || key.isEmpty || label.isEmpty) {
      debugPrint("Parameter cannot empty");
      return;
    } else {
      final division = Divisions(key: key, label: label);
      await ref.read(divisionsServiceProvider).updateDivisions(id, division);
      _refreshDivisions();
    }
  }

  Future<void> deleteDivision(String id) async {
    if (id.isEmpty) {
      debugPrint("ID cannot empty");
    } else {
      await ref.read(divisionsServiceProvider).deleteDivisions(id);
      _refreshDivisions();
    }
  }

  void _refreshDivisions() {
    ref.invalidate(allDivisions);
    ref.invalidate(divisionsById);
    ref.invalidate(divisionsByKey);
  }
}

final allDivisions = FutureProvider<List<Divisions>>((ref) {
  ref.keepAlive();
  return ref.watch(divisionsServiceProvider).fetchAllDivisions();
});

final divisionsById = FutureProvider.family<Divisions?, String>((ref, id) {
  ref.keepAlive();
  return ref.watch(divisionsServiceProvider).fetchDivisionById(id);
});

final divisionsByKey = FutureProvider.family<Divisions?, String>((ref, key) {
  ref.keepAlive();
  return ref.watch(divisionsServiceProvider).fetchDivisionByKey(key);
});
