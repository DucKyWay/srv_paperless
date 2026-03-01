import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/repositories/divisions_repo.dart';

import '../data/model/divisions_model.dart';

class DivisionsService {
  final DivisionsRepository divisionsRepo;

  DivisionsService(this.divisionsRepo);

  Future<List<Divisions>> fetchAllDivisions() async {
    return await divisionsRepo.fetchAllDivisions();
  }

  Future<Divisions?> fetchDivisionById(String id) async {
    return await divisionsRepo.fetchDivisionById(id);
  }

  Future<Divisions?> fetchDivisionByKey(String key) async {
    return await divisionsRepo.fetchDivisionByKey(key);
  }

  Future<int> createDivisions(Divisions d) async {
    return await divisionsRepo.create(d);
  }

  Future<int> updateDivisions(String uid, Divisions d) async {
    return await divisionsRepo.update(uid, d);
  }

  Future<int> deleteDivisions(String uid) async {
    return await divisionsRepo.delete(uid);
  }
}

final divisionsServiceProvider = Provider<DivisionsService>((ref) {
  final repo = ref.watch(divisionsRepoProvider);
  return DivisionsService(repo);
});
