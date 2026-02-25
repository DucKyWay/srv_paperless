import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/repositories/user_repo.dart';

import '../data/model/user_model.dart';

class UserService {
  final UserRepository userRepo;

  UserService(this.userRepo);

  Future<List<User>> getAllUsers() async {
    return await userRepo.fetchAllUsers();
  }

  Future<User?> getUserById(String id) async {
    return await userRepo.fetchUserById(id);
  }

  Future<User?> getUserByUsername(String username) async {
    return await userRepo.fetchUserByUsername(username);
  }

  Future<int> create(User user, String password) async {
    return await userRepo.create(user, password);
  }

  Future<int> updateProfileImage(String uid, String filename) async {
    return await userRepo.updateProfileImage(uid, filename);
  }

  Future<int> updatePhoneNumber(String uid, String phone) async {
    return await userRepo.updatePhoneNumber(uid, phone);
  }

  Future<int> updateAcademicDepartment(
    String uid,
    String academicDepartment,
  ) async {
    return await userRepo.updateAcademicDepartment(uid, academicDepartment);
  }

  Future<int> updateDivisions(String uid, String divisions) async {
    return await userRepo.updateDivisions(uid, divisions);
  }

  Future<int> updateHomeroomClass(String uid, String homeroomClass) async {
    return await userRepo.updateHomeroomClass(uid, homeroomClass);
  }

  Future<int> updateUser(String uid, User updatedUser) async {
    return await userRepo.update(uid, updatedUser);
  }

  Future<int> deleteUser(String uid) async {
    return await userRepo.deleteUser(uid);
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  final repo = ref.watch(userRepoProvider);
  return UserService(repo);
});
