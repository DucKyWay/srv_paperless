import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/user_model.dart';
import 'package:srv_paperless/viewmodel/academic_department_view_model.dart';
import 'package:srv_paperless/viewmodel/employee_status_view_model.dart';
import 'package:srv_paperless/viewmodel/user_view_model.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:srv_paperless/widgets/custom_dropdown.dart';
import 'package:srv_paperless/widgets/custom_text_field.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

import '../../core/utils/screen_size.dart';
import '../../viewmodel/divisions_view_model.dart';
import '../../widgets/alert_confirm_widget.dart';

class AdminManageUserScreen extends ConsumerStatefulWidget {
  final String userId;

  const AdminManageUserScreen({super.key, required this.userId});

  @override
  ConsumerState<AdminManageUserScreen> createState() =>
      _AdminManageUserScreenState();
}

class _AdminManageUserScreenState extends ConsumerState<AdminManageUserScreen> {
  final TextEditingController userFirstnameController = TextEditingController();
  final TextEditingController userLastnameController = TextEditingController();
  final TextEditingController userEmployeeStatusController =
      TextEditingController();
  final TextEditingController userAcademicDepartmentController =
      TextEditingController();
  final TextEditingController userDivisionsController = TextEditingController();
  final TextEditingController userHomeroomClassController =
      TextEditingController();

  Future<void> _loadData() async {
    debugPrint("User: ${widget.userId}");
    final userData = await ref.read(userByIdProvider(widget.userId).future);

    if (userData != null) {
      userFirstnameController.text = userData.firstname;
      userLastnameController.text = userData.lastname;
      userEmployeeStatusController.text = userData.employeeStatus;
      userAcademicDepartmentController.text = userData.academicDepartment;
      userDivisionsController.text = userData.divisions;
      userHomeroomClassController.text = userData.homeroomClass;
    }

    setState(() {});
  }

  Future<void> _saveUserHandler() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final currentUser = ref.read(userByIdProvider(widget.userId)).value;

      if (currentUser != null) {
        final updatedData = currentUser.copyWith(
          firstname: userFirstnameController.text.trim(),
          lastname: userLastnameController.text.trim(),
          employeeStatus: userEmployeeStatusController.text,
          academicDepartment: userAcademicDepartmentController.text,
          divisions: userDivisionsController.text,
          homeroomClass: userHomeroomClassController.text.trim(),
        );

        await ref
            .read(userProvider.notifier)
            .updateUser(widget.userId, updatedData);

        await ref.read(userProvider.notifier).getAllUsers();
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;

    final divisionsAsync = ref.watch(allDivisions);
    final academicAsync = ref.watch(allAcademicDepartment);
    final statusAsync = ref.watch(allEmployeeStatus);

    final userAsync = ref.watch(userByIdProvider(widget.userId));

    return MenuWidget(
      title: HeaderWithBackButton(),
      child: userAsync.when(
        data: (user) {
          if (user == null)
            return const Center(child: Text("ไม่พบข้อมูลผู้ใช้"));

          return SingleChildScrollView(
            child: SafeArea(
              child: Center(
                child: Column(
                  children: [
                    TitleNormal(des: "บัญชีผู้ใช้: ${user.username}"),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                      child: Column(
                        children: [
                          CustomTextField(
                            label: "ชื่อ:",
                            controller: userFirstnameController,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: "นามสกุล:",
                            controller: userLastnameController,
                          ),
                          const SizedBox(height: 12),

                          statusAsync.when(
                            data:
                                (items) => CustomDropdown(
                                  label: "ตำแหน่ง / สถานะ:",
                                  value:
                                      userEmployeeStatusController.text.isEmpty
                                          ? null
                                          : userEmployeeStatusController.text,
                                  items:
                                      items
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e.key,
                                              child: Text(e.label),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (val) => setState(
                                        () =>
                                            userEmployeeStatusController.text =
                                                val!,
                                      ),
                                ),
                            loading: () => const CircularProgressIndicator(),
                            error:
                                (_, __) =>
                                    Text("ไม่สามารถโหลดข้อมูลตำแหน่งงานได้"),
                          ),
                          const SizedBox(height: 12),

                          academicAsync.when(
                            data:
                                (items) => CustomDropdown(
                                  label: "กลุ่มสาระ:",
                                  value:
                                      userAcademicDepartmentController
                                              .text
                                              .isEmpty
                                          ? null
                                          : userAcademicDepartmentController
                                              .text,
                                  items:
                                      items
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e.key,
                                              child: Text(e.label),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (val) => setState(
                                        () =>
                                            userAcademicDepartmentController
                                                .text = val!,
                                      ),
                                ),
                            loading: () => const CircularProgressIndicator(),
                            error:
                                (_, __) =>
                                    Text("ไม่สามารถโหลดข้อมูลกลุ่มสาระได้"),
                          ),
                          const SizedBox(height: 12),

                          divisionsAsync.when(
                            data:
                                (items) => CustomDropdown(
                                  label: "ฝ่ายงาน:",
                                  value:
                                      userDivisionsController.text.isEmpty
                                          ? null
                                          : userDivisionsController.text,
                                  items:
                                      items
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e.key,
                                              child: Text(e.label),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (val) => setState(
                                        () =>
                                            userDivisionsController.text = val!,
                                      ),
                                ),
                            loading: () => const CircularProgressIndicator(),
                            error:
                                (_, __) =>
                                    const Text("ไม่สามารถโหลดข้อมูลฝ่ายงานได้"),
                          ),

                          const SizedBox(height: 12),
                          CustomTextField(
                            label: "ประจำชั้น:",
                            controller: userHomeroomClassController,
                          ),
                          const SizedBox(height: 16),

                          CustomButton(
                            text: const Text(
                              "บันทึกข้อมูล",
                              style: TextStyle(color: Colors.white),
                            ),
                            border: 15,
                            color: Colors.blue.shade700,
                            onPressed:
                                () => showDialog(
                                  context: context,
                                  builder:
                                      (_) => AlertConfirmWidget(
                                        title:
                                            "คุณต้องการเปลี่ยนแปลงข้อมูลหรือไม่?",
                                        onConfirm: () => _saveUserHandler(),
                                      ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
