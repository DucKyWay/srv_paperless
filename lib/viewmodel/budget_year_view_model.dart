import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/model/budget_year_model.dart';
import '../services/budget_year_service.dart';

final budgetYearProvider = AsyncNotifierProvider<BudgetYearViewModel, void>(
  BudgetYearViewModel.new,
);

class BudgetYearViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<BudgetYear?> createBudgetYear(int year) async {
    final budgetYear = BudgetYear(year: year, thisYear: false);
    int success = await ref
        .read(budgetYearServiceProvider)
        .createBudgetYear(budgetYear);

    if (success == 0) {
      debugPrint("Create Budget Year");
      _refreshBudgetYear();
      return ref.read(budgetYearServiceProvider).fetchBudgetYearByYear(year);
    } else {
      debugPrint("Failed to create budget year");
      return null;
    }
  }

  Future<void> deleteBudgetYear(String id) async {
    if (id.isEmpty) {
      debugPrint("ID cannot empty");
    } else {
      await ref.read(budgetYearServiceProvider).deleteBudgetYear(id);
      debugPrint("Deleted Budget Year");
      _refreshBudgetYear();
    }
  }

  void _refreshBudgetYear() {
    ref.invalidate(allBudgetYears);
    ref.invalidate(budgetYearById);
    ref.invalidate(budgetYearByYear);
    ref.invalidate(budgetYearByThisYear);
  }
}

final allBudgetYears = FutureProvider<List<BudgetYear>>((ref) {
  return ref.watch(budgetYearServiceProvider).fetchAllBudgetYears();
});

final budgetYearById = FutureProvider.family<BudgetYear?, String>((ref, id) {
  return ref.watch(budgetYearServiceProvider).fetchBudgetYearById(id);
});

final budgetYearByYear = FutureProvider.family<BudgetYear?, int>((ref, year) {
  return ref.watch(budgetYearServiceProvider).fetchBudgetYearByYear(year);
});

final budgetYearByThisYear = FutureProvider<BudgetYear?>((ref) {
  return ref.watch(budgetYearServiceProvider).fetchBudgetYearByThisYear();
});
