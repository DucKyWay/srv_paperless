import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/repositories/budget_year_repo.dart';

import '../data/model/budget_year_model.dart';

class BudgetYearService {
  final BudgetYearRepository budgetYearRepo;

  BudgetYearService(this.budgetYearRepo);

  Future<List<BudgetYear>> fetchAllBudgetYears() async {
    return await budgetYearRepo.fetchAllBudgetYears();
  }

  Future<BudgetYear?> fetchBudgetYearById(String id) async {
    return await budgetYearRepo.fetchBudgetYearById(id);
  }

  Future<BudgetYear?> fetchBudgetYearByYear(int year) async {
    return await budgetYearRepo.fetchBudgetYearByYear(year);
  }

  Future<BudgetYear?> fetchBudgetYearByThisYear() async {
    return await budgetYearRepo.fetchBudgetYearByThisYear();
  }

  Future<int> createBudgetYear(BudgetYear budgetYear) async {
    return await budgetYearRepo.create(budgetYear);
  }

  Future<int> updateBudgetYear(String id, BudgetYear budgetYear) async {
    return await budgetYearRepo.update(id, budgetYear);
  }

  Future<int> deleteBudgetYear(String id) async {
    return await budgetYearRepo.delete(id);
  }
}

final budgetYearServiceProvider = Provider<BudgetYearService>((ref) {
  final repo = ref.watch(budgetYearRepoProvider);
  return BudgetYearService(repo);
});
