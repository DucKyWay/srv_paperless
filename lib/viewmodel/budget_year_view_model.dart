import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/model/budget_year_model.dart';
import '../services/budget_year_service.dart';

final budgetYearViewModelProvider =
    AsyncNotifierProvider<BudgetYearViewModel, void>(BudgetYearViewModel.new);

class BudgetYearViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> createBudgetYear(int year) async {
    final budgetYear = BudgetYear(year: year, thisYear: false);
    int success = await ref
        .read(budgetYearServiceProvider)
        .createBudgetYear(budgetYear);

    if (success == 0) {
      _refreshBudgetYear();
      return true;
    }
    return false;
  }

  Future<bool> updateBudgetYear(String id, BudgetYear budgetYear) async {
    int success = await ref
        .read(budgetYearServiceProvider)
        .updateBudgetYear(id, budgetYear);

    if (success == 0) {
      _refreshBudgetYear();
      return true;
    }
    return false;
  }

  Future<bool> setThisYear(String id) async {
    final currentThisYear =
        await ref.read(budgetYearServiceProvider).fetchBudgetYearByThisYear();
    if (currentThisYear != null && currentThisYear.id != null) {
      await ref
          .read(budgetYearServiceProvider)
          .updateBudgetYear(
            currentThisYear.id!,
            currentThisYear.copyWith(thisYear: false),
          );
    }

    final target = await ref
        .read(budgetYearServiceProvider)
        .fetchBudgetYearById(id);
    if (target != null) {
      int success = await ref
          .read(budgetYearServiceProvider)
          .updateBudgetYear(id, target.copyWith(thisYear: true));
      if (success == 0) {
        _refreshBudgetYear();
        return true;
      }
    }
    return false;
  }

  Future<void> deleteBudgetYear(String id) async {
    await ref.read(budgetYearServiceProvider).deleteBudgetYear(id);
    _refreshBudgetYear();
  }

  void _refreshBudgetYear() {
    ref.invalidate(allBudgetYearsProvider);
    ref.invalidate(budgetYearByThisYearProvider);
  }
}

final allBudgetYearsProvider = FutureProvider<List<BudgetYear>>((ref) {
  return ref.watch(budgetYearServiceProvider).fetchAllBudgetYears();
});

final budgetYearByThisYearProvider = FutureProvider<BudgetYear?>((ref) {
  return ref.watch(budgetYearServiceProvider).fetchBudgetYearByThisYear();
});
