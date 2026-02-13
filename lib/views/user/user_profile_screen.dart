import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:srv_paperless/core/utils/async_value_ext.dart';
import 'package:srv_paperless/data/minio.dart';
import 'package:srv_paperless/data/repositories/academic_department_repo.dart';
import 'package:srv_paperless/data/repositories/divisions_repo.dart';
import 'package:srv_paperless/data/repositories/employee_status_repo.dart';
import 'package:srv_paperless/data/repositories/user_repo.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:srv_paperless/widgets/custom_text_field.dart';
import 'package:srv_paperless/widgets/image_source_sheet.dart';
import 'package:srv_paperless/widgets/main_layout.dart';
import 'package:srv_paperless/widgets/menu_header.dart';
import 'package:srv_paperless/widgets/user_profile/change_password_dialog.dart';
import 'package:srv_paperless/widgets/user_profile/profile_avatar.dart';
import 'package:srv_paperless/widgets/user_profile/profile_info.dart';

class UserProfile extends ConsumerStatefulWidget {
  const UserProfile({super.key});

  @override
  ConsumerState<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends ConsumerState<UserProfile> {
  Future<void> _changeProfileImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        final user = ref.read(authProvider).currentUser!;
        final uid = user.id;

        if (user.image.isNotEmpty && user.image != "user.png") {
          await deleteFile('srv-paperless', user.image);
        }

        final String filename =
            "profile_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";

        await uploadFile('srv-paperless', filename, image.path);

        await ref.read(userRepoProvider).updateProfileImage(uid, filename);

        ref.invalidate(authProvider);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("อัปเดตรูปโปรไฟล์สำเร็จ"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เกิดข้อผิดพลาด: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceActionSheet() {
  showModalBottomSheet(
    context: context,
    builder: (context) => ImageSourceSheet(
      onSourceSelected: (source) => _changeProfileImage(source),
    ),
  );
}

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

    final employeeStatusAsync = ref.watch(
      getEmployeeStatusByKey(user.employeeStatus),
    );
    final departmentAsync = ref.watch(
      getDepartmentByKey(user.academicDepartment),
    );
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
              ProfileAvatar(
                imageName: user.image,
                onTap: _showImageSourceActionSheet,
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
                    ProfileInfoRow(topic: "ชื่อ-นามสกุล:", info: user.fullname),
                    const SizedBox(height: 8),
                    ProfileInfoRow(
                      topic: "ตำแหน่ง:",
                      info: employeeStatusAsync.labelText,
                    ),
                    const SizedBox(height: 8),
                    ProfileInfoRow(
                      topic: "กลุ่มสาระ:",
                      info: departmentAsync.labelText,
                    ),
                    const SizedBox(height: 8),
                    ProfileInfoRow(
                      topic: "ฝ่ายงาน:",
                      info: divisionAsync.labelText,
                    ),
                    const SizedBox(height: 8),
                    ProfileInfoRow(
                      topic: "ประจำชั้น:",
                      info: user.homeroomClass,
                    ),
                    SizedBox(height: 45),
                    CustomTextField(
                      label: "เบอร์โทร",
                      hint: user.phone,
                      controller: phoneController,
                    ),
                    SizedBox(height: 45),
                    CustomButton(
                      height: 55,
                      text: Text(
                        "เปลี่ยนรหัสผ่าน",
                        style: TextStyle(color: Colors.white),
                      ),
                      border: 15,
                      color: Color(0x1D4200).withOpacity(1),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => ChangePasswordDialog(),
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    CustomButton(
                      height: 55,
                      text: Text(
                        "ยืนยัน",
                        style: TextStyle(color: Colors.white),
                      ),
                      border: 15,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      onPressed: () {},
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
