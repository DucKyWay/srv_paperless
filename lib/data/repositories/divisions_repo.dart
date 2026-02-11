import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/db_manager.dart';
import 'package:srv_paperless/data/model/divisions_model.dart';

abstract class DivisionsRepository {
  Future<List<Divisions>> getAllDivisionss();
  Future<Divisions?> getDivisionsById(int id);
  Future<Divisions?> getDivisionsByKey(String key);
  Future<Divisions?> getDivisionsByLabel(String label);
}

class DivisionsRepositoryImpl implements DivisionsRepository {
  final DbManager db;
  final Ref ref;
  DivisionsRepositoryImpl(this.db, this.ref);

  @override
  Future<Divisions?> getDivisionsById(int id) async {
    final maps = await db.query(
      "SELECT * FROM academic_department WHERE a_department_id = ?",
      [id]
    );

    if (maps.isNotEmpty) {
      return Divisions.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<Divisions?> getDivisionsByKey(String key) async {
    final maps = await db.query(
      "SELECT * FROM academic_department WHERE a_department_key = ?",
      [key]
    );

    if (maps.isNotEmpty) {
      return Divisions.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<Divisions?> getDivisionsByLabel(String label) async {
    final maps = await db.query(
      "SELECT * FROM academic_department WHERE a_department_label = ?",
      [label]
    );

    if (maps.isNotEmpty) {
      return Divisions.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<Divisions>> getAllDivisionss() async {
    final List<Map<String, dynamic>> maps = await db.query('academic_department');
    
    return List.generate(maps.length, (i) {
      return Divisions.fromMap(maps[i]);
    });
  }
}

final divisionsRepoProvider = Provider<DivisionsRepository>((ref) {
  final db = DbManager();
  return DivisionsRepositoryImpl(db, ref);
});