import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/db_manager.dart';
import 'package:srv_paperless/data/model/divisions_model.dart';

abstract class DivisionsRepository {
  Future<List<Divisions>> fetchAllDivisions();
  Future<Divisions?> fetchDivisionById(int id);
  Future<Divisions?> fetchDivisionByKey(String key);
}

class DivisionsRepositoryImpl implements DivisionsRepository {
  final DbManager db;
  final Ref ref;
  DivisionsRepositoryImpl(this.db, this.ref);

  @override
  Future<Divisions?> fetchDivisionById(int id) async {
    final maps = await db.query(
      "SELECT division_id, division_key, division_label FROM divisions WHERE division_id = ?",
      [id],
    );

    if (maps.isNotEmpty) {
      return Divisions.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<Divisions?> fetchDivisionByKey(String key) async {
    final maps = await db.query(
      "SELECT division_id, division_key, division_label FROM divisions WHERE division_key = ?",
      [key]
    );

    if (maps.isNotEmpty) {
      return Divisions.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<Divisions>> fetchAllDivisions() async {
    final List<Map<String, dynamic>> maps = await db.query('divisions');
    
    return List.generate(maps.length, (i) {
      return Divisions.fromMap(maps[i]);
    });
  }
}

final divisionsRepoProvider = Provider<DivisionsRepository>((ref) {
  final db = DbManager();
  return DivisionsRepositoryImpl(db, ref);
});

// ===== Provider =====

final getAllDivisions = FutureProvider<List<Divisions>>((ref) async {
  final repo = ref.watch(divisionsRepoProvider);
  return await repo.fetchAllDivisions();
});

final getDivisionsByKey = FutureProvider.family<Divisions?, String>((ref, key) async {
  final repo = ref.watch(divisionsRepoProvider);
  return await repo.fetchDivisionByKey(key);
});
