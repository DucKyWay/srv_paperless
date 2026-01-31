import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/model/user.dart';
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
class AuthState {
  final bool isLoading;
  final User? currentUser; // เปลี่ยนจาก String? role
  final String? error;

  AuthState({this.isLoading = false, this.currentUser, this.error});

  AuthState copyWith({bool? isLoading, User? currentUser, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      error: error ?? this.error,
    );
  }
  
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState();

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    await Future.delayed(const Duration(seconds: 1)); // ลดเวลาลงหน่อยจะได้ไม่รอนาน

    if (username == "admin" && password == "1234") {
      // ตัวอย่าง User ระดับบริหาร/งบประมาณ
      final adminUser = User(
        id: "USR001",
        username: "admin",
        fullname: "ดร.สมชาย ใจดี",
        phone: "0812345678",
        academicDepartment: AcademicDepartment.science,
        division: Division.budget,
        homeroomClass: "-",
        employeeStatus: EmployeeStatus.director,
      );
      state = state.copyWith(isLoading: false, currentUser: adminUser);
      
    } else if (username == "user" && password == "1234") {
      // ตัวอย่าง User คุณครู
      final teacherUser = User(
        id: "USR002",
        username: "user",
        fullname: "นางสาวสมศรี เรียนดี",
        phone: "0898765432",
        academicDepartment: AcademicDepartment.science,
        division: Division.budget,
        homeroomClass: "ม.5/1",
        employeeStatus: EmployeeStatus.civilServant,
      );
      state = state.copyWith(isLoading: false, currentUser: teacherUser);
      
    } else {
      state = state.copyWith(isLoading: false, error: "Username หรือ Password ผิด");
    }
    
  }

  void logout() => state = AuthState();
  
}