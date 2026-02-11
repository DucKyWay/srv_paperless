import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/repositories/academic_department_repo.dart';
import 'package:srv_paperless/data/repositories/divisions_repo.dart';
import 'package:srv_paperless/data/repositories/employee_status_repo.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/widgets/custom_text_field.dart';
import 'package:srv_paperless/widgets/main_layout.dart';
import 'package:srv_paperless/widgets/menu_header.dart';

class UserProfile extends ConsumerStatefulWidget {
  const UserProfile({super.key});

  @override
  ConsumerState<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends ConsumerState<UserProfile> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;
    final TextEditingController phoneController = TextEditingController();
    if (user == null) {
      return MainLayout(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ระบบโครงการออนไลน์",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Text(
              "นโยบายและแผนงาน โรงเรียนสารวิทยา",
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
        child: Center(child: Text("กรุณาเข้าสู่ระบบ")),
      );
    }

    final employeeStatusAsync = ref.watch(getEmployeeStatusByKey(user.employeeStatus));
    final departmentAsync = ref.watch(getDepartmentByKey(user.academicDepartment));
    final divisionAsync = ref.watch(getDivisionsByKey(user.divisions));

    return MainLayout(
      title: const BackButtonHeader(),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Image.asset(
                "assets/images/${user.image}",
                fit: BoxFit.contain,
                height: 150,
              ),
              SizedBox(height: 20),
              Text(
                user.username,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    info("ชื่อ-นามสกุล:", user.fullname),
                    const SizedBox(height: 8),
                    employeeStatusAsync.when(
                      data: (dept) => info(
                        "ตำแหน่ง:",
                        dept?.label ?? "ไม่พบข้อมูล ($user.employeeStatus)",
                      ),
                      loading: () => info("ตำแหน่ง:", "กำลังโหลด..."),
                      error: (err, _) => info("ตำแหน่ง:", "ข้อผิดพลาด: $err"),
                    ),
                    const SizedBox(height: 8),
                    departmentAsync.when(
                      data: (dept) => info(
                        "กลุ่มสาระ:",
                        dept?.label ?? "ไม่พบข้อมูล ($user.academicDepartment)",
                      ),
                      loading: () => info("กลุ่มสาระ:", "กำลังโหลด..."),
                      error: (err, _) => info("กลุ่มสาระ:", "ข้อผิดพลาด: $err"),
                    ),
                    const SizedBox(height: 8),
                    divisionAsync.when(
                      data: (dept) => info(
                        "ฝ่ายงาน:",
                        dept?.label ?? "ไม่พบข้อมูล ($user.divisions)",
                      ),
                      loading: () => info("ฝ่ายงาน:", "กำลังโหลด..."),
                      error: (err, _) => info("ฝ่ายงาน:", "ข้อผิดพลาด: $err"),
                    ),
                    const SizedBox(height: 8),
                    info("ประจำชั้น:", user.homeroomClass),
                    SizedBox(height: 45),
                    CustomTextField(
                      label: "เบอร์โทร",
                      hint: user.phone,
                      controller: phoneController,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget info(String topic, String info) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        topic,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(info, style: const TextStyle(fontSize: 16), softWrap: true),
      ),
    ],
  );
}
