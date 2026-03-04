import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/budget_year_model.dart';

abstract class BudgetYearRepository {
  Future<List<BudgetYear>> fetchAllBudgetYears();
  Future<BudgetYear?> fetchBudgetYearById(String id);
  Future<BudgetYear?> fetchBudgetYearByYear(int year);
  Future<BudgetYear?> fetchBudgetYearByThisYear();
  Future<int> create(BudgetYear budgetYear);
  Future<int> delete(String id);
}

class BudgetYearRepositoryImpl implements BudgetYearRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<int> create(BudgetYear budgetYear) async {
    try {
      final doc = _db.collection('budget_years').doc();
      final newBudgetYear = budgetYear.copyWith(id: doc.id);
      await doc.set(newBudgetYear.toMap());
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> delete(String id) async {
    try {
      final budgetYear = await fetchBudgetYearById(id);
      if (budgetYear != null) {
        await _db.collection('budget_years').doc(id).delete();
        return 0;
      } else {
        return 1;
      }
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<List<BudgetYear>> fetchAllBudgetYears() async {
    try {
      final snapshot =
          await _db
              .collection('budget_years')
              .orderBy('year', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => BudgetYear.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<BudgetYear?> fetchBudgetYearById(String id) async {
    try {
      final doc = await _db.collection('budget_years').doc(id).get();
      return doc.exists ? BudgetYear.fromMap(doc.data()!, doc.id) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<BudgetYear?> fetchBudgetYearByYear(int year) async {
    try {
      final snapshot =
          await _db
              .collection('budget_years')
              .where('year', isEqualTo: year)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return BudgetYear.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<BudgetYear?> fetchBudgetYearByThisYear() async {
    try {
      final snapshot =
          await _db
              .collection('budget_year')
              .where('this_year', isEqualTo: true)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return BudgetYear.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final budgetYearRepoProvider = Provider<BudgetYearRepository>(
  (ref) => BudgetYearRepositoryImpl(),
);
