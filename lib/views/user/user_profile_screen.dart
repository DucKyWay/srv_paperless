import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/repositories/academic_department_repo.dart';
import 'package:srv_paperless/data/repositories/divisions_repo.dart';
import 'package:srv_paperless/data/repositories/employee_status_repo.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/viewmodel/user_view_model.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:srv_paperless/widgets/custom_text_field.dart';
import 'package:srv_paperless/widgets/image_source_sheet.dart';
import 'package:srv_paperless/widgets/main_layout.dart';
import 'package:srv_paperless/widgets/menu_header.dart';
import 'package:srv_paperless/widgets/user_profile/change_password_dialog.dart';
import 'package:srv_paperless/widgets/user_profile/profile_avatar.dart';
import 'package:srv_paperless/widgets/user_profile/profile_info.dart';

class UserProfile extends ConsumerWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(userProfileProvider);
    final user = authState.currentUser;
    final phoneController = TextEditingController();

    ref.listen<AsyncValue<void>>(userProfileProvider, (previous, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เกิดข้อผิดพลาด: $e"), backgroundColor: Colors.red),
        ),
        data: (_) {
          if (previous is AsyncLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("ดำเนินการสำเร็จ"), backgroundColor: Colors.green),
            );
          }
        },
      );
    });

    if (user == null) {
      return _buildLoginRequired(context);
    }

    final employeeStatusAsync = ref.watch(getEmployeeStatusByKey(user.employeeStatus));
    final departmentAsync = ref.watch(getDepartmentByKey(user.academicDepartment));
    final divisionAsync = ref.watch(getDivisionsByKey(user.divisions));

    return Stack(
      children: [
        MainLayout(
          title: const BackButtonHeader(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ProfileAvatar(
                    imageName: user.image,
                    onTap: () => _showImageSourceActionSheet(context, ref),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.username,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  
                  ProfileInfoRow(topic: "ชื่อ-นามสกุล:", info: user.fullname),
                  ProfileInfoRow(topic: "ตำแหน่ง:", info: employeeStatusAsync.value?.label ?? "-"),
                  ProfileInfoRow(topic: "กลุ่มสาระ:", info: departmentAsync.value?.label ?? "-"),
                  ProfileInfoRow(topic: "ฝ่ายงาน:", info: divisionAsync.value?.label ?? "-"),
                  ProfileInfoRow(topic: "ประจำชั้น:", info: user.homeroomClass),
                  
                  const SizedBox(height: 41),
                  CustomTextField(
                    label: "เบอร์โทร",
                    hint: user.phone,
                    controller: phoneController,
                  ),
                  
                  const SizedBox(height: 45),
                  CustomButton(
                    height: 55,
                    text: const Text("เปลี่ยนรหัสผ่าน", style: TextStyle(color: Colors.white)),
                    border: 15,
                    color: const Color(0xFF1D4200),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const ChangePasswordDialog(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    height: 55,
                    text: const Text("ยืนยันการแก้ไข", style: TextStyle(color: Colors.white)),
                    border: 15,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    onPressed: () {
                      if (phoneController.text.isNotEmpty) {
                        ref.read(userProfileProvider.notifier).updatePhoneNumber(phoneController.text);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        
        if (profileState is AsyncLoading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  void _showImageSourceActionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ImageSourceSheet(
        onSourceSelected: (source) {
          Navigator.pop(context);
          ref.read(userProfileProvider.notifier).updateProfileImage(source);
        },
      ),
    );
  }

  Widget _buildLoginRequired(BuildContext context) {
    return MainLayout(
      title: const NormalHeader(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("กรุณาเข้าสู่ระบบ", style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            CustomButton(
              height: 55,
              text: const Text("เข้าสู่ระบบ", style: TextStyle(color: Colors.white)),
              border: 15,
              color: Theme.of(context).colorScheme.primaryContainer,
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
          ],
        ),
      ),
    );
  }
}