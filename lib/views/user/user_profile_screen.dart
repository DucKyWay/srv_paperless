import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/widgets/custom_text_field.dart';
import 'package:srv_paperless/widgets/main_layout.dart';

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
                    info("ตำแหน่ง:", user.employeeStatus.label),
                    const SizedBox(height: 8),
                    info("กลุ่มสาระ:", user.academicDepartment.label),
                    const SizedBox(height: 8),
                    info("ฝ่ายงาน:", user.division.label),
                    const SizedBox(height: 8),
                    info(
                      "ประจำชั้น:",
                      user.homeroomClass,
                    ),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          info,
          style: const TextStyle(fontSize: 16),
          softWrap: true,
        ),
      ),
    ],
  );
}