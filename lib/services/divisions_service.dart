import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/repositories/divisions_repo.dart';

import '../data/model/divisions_model.dart';

class DivisionsService {
  final DivisionsRepository divisionsRepo;

  DivisionsService(this.divisionsRepo);

  Future<List<Divisions>> getAllDivisions() async {
    return await divisionsRepo.fetchAllDivisions();
  }
  Future<Divisions?> getDivisionById(String id) async {
    return await divisionsRepo.fetchDivisionById(id);
  }
  Future<Divisions?> getDivisionByKey(String key) async {
    return await divisionsRepo.fetchDivisionByKey(key);
  }
}

final divisionsServiceProvider = Provider<DivisionsService>((ref) {
  final repo = ref.watch(divisionsRepoProvider);
  return DivisionsService(repo);
});