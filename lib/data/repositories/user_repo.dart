import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../model/user_model.dart';

abstract class UserRepository {
  Future<List<User>> fetchAllUsers();
  Future<User?> fetchUserById(String id);
  Future<User?> fetchUserByUsername(String username);

  Future<void> create(User user, String password);

  Future<User?> getCurrentUser();
  Future<void> updateProfileImage(String uid, String filename);
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
    final snapshot = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return User.fromMap(doc.data(), doc.id);
  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      return await fetchUserById(firebaseUser.uid);
    }
    return null;
  }

  @override
  Future<void> create(User user, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: user.username,
      password: password,
    );

    final newUser = user.copyWith(id: credential.user!.uid);
    await _db.collection('users').doc(newUser.id).set(newUser.toMap());
  }

  @override
  Future<void> updateProfileImage(String uid, String filename) async {
     await _db.collection('users').doc(uid).update({'image': filename});
  }
}

final userRepoProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(),
);
