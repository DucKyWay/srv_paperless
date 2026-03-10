import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../model/user_model.dart';

abstract class UserRepository {
  Future<List<User>> fetchAllUsers();
  Future<User?> fetchUserById(String id);
  Future<User?> fetchUserByUsername(String username);

  Future<int> create(User user, String password);
  Future<int> update(String uid, User updatedUser);
  Future<int> updateProfileImage(String uid, String filename);
  Future<int> updatePhoneNumber(String uid, String phone);
  Future<int> updateAcademicDepartment(String uid, String academicDepartment);
  Future<int> updateDivisions(String uid, String divisions);
  Future<int> updateHomeroomClass(String uid, String homeroomClass);
  Future<int> deleteUser(String uid);
}

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  @override
  Future<List<User>> fetchAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs
        .map((doc) => User.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<User?> fetchUserById(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    return doc.exists ? User.fromMap(doc.data()!, doc.id) : null;
  }

  @override
  Future<User?> fetchUserByUsername(String username) async {
    final snapshot =
        await _db
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return User.fromMap(doc.data(), doc.id);
  }

  @override
  Future<int> create(User user, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: user.username,
        password: password,
      );

      final newUser = user.copyWith(id: credential.user!.uid);
      await _db.collection('users').doc(newUser.id).set(newUser.toMap());
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> updatePhoneNumber(String uid, String phone) async {
    try {
      await _db.collection('users').doc(uid).update({'phone': phone});
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> updateProfileImage(String uid, String filename) async {
    try {
      await _db.collection('users').doc(uid).update({'image': filename});
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> updateAcademicDepartment(
    String uid,
    String academicDepartment,
  ) async {
    try {
      await _db.collection('users').doc(uid).update({
        'academic_department': academicDepartment,
      });
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> updateDivisions(String uid, String divisions) async {
    try {
      await _db.collection('users').doc(uid).update({'divisions': divisions});
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> updateHomeroomClass(String uid, String homeroomClass) async {
    try {
      await _db.collection('users').doc(uid).update({
        'homeroom_class': homeroomClass,
      });
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> deleteUser(String uid) async {
    try {
      final user = await fetchUserById(uid);

      if (user != null) {
        await _db.collection('users').doc(uid).delete();
        return 0;
      } else {
        return 1;
      }
    } catch (e) {
      return -1;
    }
  }

  @override
  Future<int> update(String uid, User updatedUser) async {
    try {
      await _db.collection('users').doc(uid).update(updatedUser.toMap());
      return 0;
    } catch (e) {
      return 1;
    }
  }
}

final userRepoProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(),
);
