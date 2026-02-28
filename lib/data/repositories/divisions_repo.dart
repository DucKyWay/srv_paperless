import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/divisions_model.dart';

abstract class DivisionsRepository {
  Future<List<Divisions>> fetchAllDivisions();
  Future<Divisions?> fetchDivisionById(String id);
  Future<Divisions?> fetchDivisionByKey(String key);
  Future<int> create(Divisions d);
  Future<int> update(String uid, Divisions newD);
  Future<int> delete(String uid);
}

class DivisionsRepositoryImpl implements DivisionsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<Divisions?> fetchDivisionById(String id) async {
    final doc = await _db.collection('divisions').doc(id).get();

    if (doc.exists) {
      return Divisions.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<Divisions?> fetchDivisionByKey(String key) async {
    final snapshot = await _db
        .collection('divisions')
        .where('key', isEqualTo: key)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return Divisions.fromMap(doc.data(), doc.id);
    }
    return null;
  }

  @override
  Future<List<Divisions>> fetchAllDivisions() async {
    final snapshot = await _db.collection('divisions').get();

    return snapshot.docs.map((doc) {
      return Divisions.fromMap(doc.data(), doc.id);
    }).toList();
  }
  
  @override
  Future<int> create(Divisions d) async {
    try {
      final doc = _db.collection('divisions').doc();
      final newD = d.copyWith(id: doc.id);
      await doc.set(newD.toMap());
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> delete(String uid) async {
    try {
      final d = await fetchDivisionById(uid);

      if(d != null) {
        await _db.collection('divisions').doc(uid).delete();
        return 0;
      } else {
        return 1;
      }
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> update(String uid, Divisions newD) async {
    try {
      await _db.collection('divisions').doc(uid).update(newD.toMap());
      return 0;
    } catch (e) {
      return 1;
    }
  }
}

final divisionsRepoProvider = Provider<DivisionsRepository>(
  (ref) => DivisionsRepositoryImpl(),
);