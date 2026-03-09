import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/routes/app_routes.dart';
import 'package:srv_paperless/viewmodel/academic_department_view_model.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/viewmodel/divisions_view_model.dart';
import 'package:srv_paperless/viewmodel/employee_status_view_model.dart';
import 'package:srv_paperless/viewmodel/user_view_model.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:srv_paperless/widgets/custom_text_field.dart';
import 'package:srv_paperless/widgets/image_source_sheet.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/user_profile/change_password_dialog.dart';
import 'package:srv_paperless/widgets/user_profile/profile_avatar.dart';
import 'package:srv_paperless/widgets/user_profile/profile_info.dart';

class UserProfile extends ConsumerWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(userProvider);
    final user = authState.value?.currentUser;
    final phoneController = TextEditingController();

    ref.listen<AsyncValue<void>>(userProvider, (previous, next) {
      next.whenOrNull(
        error: (e, _) => _showSnackBar(context, "เกิดข้อผิดพลาด", Colors.red),
        data: (_) {
          if (previous is AsyncLoading) {
            _showSnackBar(context, "ดำเนินการสำเร็จ", Colors.green);
          }
        },
      );
    });

    if (user == null) {
      Navigator.pushNamed(context, AppRoutes.login);
    }

    final employeeStatusAsync = ref.watch(
      employeeStatusByKey(user!.employeeStatus),
    );
    final departmentAsync = ref.watch(
      academicDepartmentByKey(user.academicDepartment),
    );
    final divisionAsync = ref.watch(divisionsByKey(user.divisions));

    return Stack(
      children: [
        MenuWidget(
          title: const HeaderWithBackButton(),
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  ProfileInfoRow(topic: "ชื่อ-นามสกุล:", info: user.fullname),
                  ProfileInfoRow(
                    topic: "ตำแหน่ง:",
                    info: employeeStatusAsync.value?.label ?? "-",
                  ),
                  ProfileInfoRow(
                    topic: "กลุ่มสาระ:",
                    info: departmentAsync.value?.label ?? "-",
                  ),
                  ProfileInfoRow(
                    topic: "ฝ่ายงาน:",
                    info: divisionAsync.value?.label ?? "-",
                  ),
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
                    text: const Text(
                      "เปลี่ยนรหัสผ่าน",
                      style: TextStyle(color: Colors.white),
                    ),
                    border: 15,
                    color: const Color(0xFF1D4200),
                    onPressed:
                        () => showDialog(
                          context: context,
                          builder: (_) => const ChangePasswordDialog(),
                        ),
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    height: 55,
                    text: const Text(
                      "ยืนยันการแก้ไข",
                      style: TextStyle(color: Colors.white),
                    ),
                    border: 15,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    onPressed: () {
                      if (phoneController.text.isNotEmpty) {
                        ref
                            .read(userProvider.notifier)
                            .updatePhoneNumber(phoneController.text);
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
      builder:
          (context) => ImageSourceSheet(
            onSourceSelected: (source) {
              ref.read(userProvider.notifier).updateProfileImage(source);
            },
          ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showSnackBar(
    BuildContext context,
    String text,
    Color color,
  ) {
    return ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
  }
}
