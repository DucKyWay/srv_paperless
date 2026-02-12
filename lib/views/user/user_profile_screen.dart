import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:srv_paperless/core/utils/async_value_ext.dart';
import 'package:srv_paperless/data/minio.dart';
import 'package:srv_paperless/data/repositories/academic_department_repo.dart';
import 'package:srv_paperless/data/repositories/divisions_repo.dart';
import 'package:srv_paperless/data/repositories/employee_status_repo.dart';
import 'package:srv_paperless/data/repositories/user_repo.dart';
import 'package:srv_paperless/services/auth_service.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:srv_paperless/widgets/custom_text_field.dart';
import 'package:srv_paperless/widgets/main_layout.dart';
import 'package:srv_paperless/widgets/menu_header.dart';

class UserProfile extends ConsumerStatefulWidget {
  const UserProfile({super.key});

  @override
  ConsumerState<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends ConsumerState<UserProfile> {
  void _showChangePasswordDialog() {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("เปลี่ยนรหัสผ่านใหม่"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "รหัสผ่านใหม่"),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "ยืนยันรหัสผ่านใหม่",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text ==
                      confirmPasswordController.text &&
                  newPasswordController.text.isNotEmpty) {
                try {
                  await ref
                      .read(authServiceProvider)
                      .changePassword(newPasswordController.text);

                  if (context.mounted) {
                    Navigator.pop(context); // ปิด Dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("เปลี่ยนรหัสผ่านสำเร็จ"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("รหัสผ่านไม่ตรงกัน"),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text("บันทึก"),
          ),
        ],
      ),
    );
  }

  Future<void> _changeProfileImage(ImageSource source) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: source);

  if (image != null) {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final user = ref.read(authProvider).currentUser!;
      final uid = user.id;
      
      if (user.image.isNotEmpty && user.image != "user.png") {
        await deleteFile('srv-paperless', user.image);
      }

      final String filename = "profile_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      await uploadFile('srv-paperless', filename, image.path);

      await ref.read(userRepoProvider).updateProfileImage(uid, filename);

      ref.invalidate(authProvider); 

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("อัปเดตรูปโปรไฟล์สำเร็จ"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $e"), backgroundColor: Colors.red),
      );
    }
  }
}
  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('ถ่ายรูปใหม่'),
              onTap: () {
                Navigator.pop(context);
                _changeProfileImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('เลือกจากแกลเลอรี่'),
              onTap: () {
                Navigator.pop(context);
                _changeProfileImage(ImageSource.gallery);
              },
            ),
          ],
        ),
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
              GestureDetector(
                onTap: _showImageSourceActionSheet,
                child: Stack(
                  children: [
                    FutureBuilder<String>(
                      future: getPrivateImageUrl(user.image),
                      builder: (context, snapshot) {
                        final String? imageUrl = snapshot.data;

                        return GestureDetector(
                          onTap: _showImageSourceActionSheet,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 75,
                                backgroundColor: Colors.grey[200],
                                backgroundImage:
                                    (imageUrl != null && imageUrl.isNotEmpty)
                                    ? NetworkImage(imageUrl) as ImageProvider
                                    : const AssetImage(
                                        "assets/images/user.png",
                                      ),
                                child:
                                    snapshot.connectionState ==
                                        ConnectionState.waiting
                                    ? const CircularProgressIndicator()
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  radius: 20,
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        radius: 20,
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
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
                    info("ตำแหน่ง:", employeeStatusAsync.labelText),
                    const SizedBox(height: 8),
                    info("กลุ่มสาระ:", departmentAsync.labelText),
                    const SizedBox(height: 8),
                    info("ฝ่ายงาน:", divisionAsync.labelText),
                    const SizedBox(height: 8),
                    info("ประจำชั้น:", user.homeroomClass),
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
                        _showChangePasswordDialog();
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
