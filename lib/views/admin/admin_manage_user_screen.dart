import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final userFirstnameController = TextEditingController();
  final userLastnameController = TextEditingController();
  final userHomeroomClassController = TextEditingController();

  String? selectedEmployeeStatus;
  String? selectedAcademicDepartment;
  String? selectedDivision;

  bool _initialized = false;

  @override
  void dispose() {
    userFirstnameController.dispose();
    userLastnameController.dispose();
    userHomeroomClassController.dispose();
    super.dispose();
  }

  Future<void> _saveUserHandler() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final currentUser = await ref.read(
        userByIdProvider(widget.userId).future,
      );

      if (currentUser == null) return;

      final updatedData = currentUser.copyWith(
        firstname: userFirstnameController.text.trim(),
        lastname: userLastnameController.text.trim(),
        employeeStatus: selectedEmployeeStatus,
        academicDepartment: selectedAcademicDepartment,
        divisions: selectedDivision,
        homeroomClass: userHomeroomClassController.text.trim(),
      );

      await ref
          .read(userProvider.notifier)
          .updateUser(widget.userId, updatedData);

      ref.watch(allUsersProvider);

      if (mounted) {
        Navigator.pop(context); // close loading
        Navigator.pop(context); // back
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;

    final userAsync = ref.watch(userByIdProvider(widget.userId));
    final divisionsAsync = ref.watch(allDivisions);
    final academicAsync = ref.watch(allAcademicDepartment);
    final statusAsync = ref.watch(allEmployeeStatus);

    return MenuWidget(
      title: HeaderWithBackButton(),
      child: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("ไม่พบข้อมูลผู้ใช้"));
          }

          if (!_initialized) {
            userFirstnameController.text = user.firstname;
            userLastnameController.text = user.lastname;
            userHomeroomClassController.text = user.homeroomClass;

            selectedEmployeeStatus = user.employeeStatus;
            selectedAcademicDepartment = user.academicDepartment;
            selectedDivision = user.divisions;

            _initialized = true;
          }

          return SingleChildScrollView(
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                  child: Column(
                    children: [
                      TitleNormal(des: "บัญชีผู้ใช้: ${user.username}"),

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

                      /// Employee Status
                      statusAsync.when(
                        data:
                            (items) => CustomDropdown(
                              label: "ตำแหน่ง / สถานะ:",
                              value: selectedEmployeeStatus,
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
                                    () => selectedEmployeeStatus = val,
                                  ),
                            ),
                        loading: () => const CircularProgressIndicator(),
                        error:
                            (_, __) =>
                                const Text("ไม่สามารถโหลดข้อมูลตำแหน่งงานได้"),
                      ),

                      const SizedBox(height: 12),

                      /// Academic Department
                      academicAsync.when(
                        data:
                            (items) => CustomDropdown(
                              label: "กลุ่มสาระ:",
                              value: selectedAcademicDepartment,
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
                                    () => selectedAcademicDepartment = val,
                                  ),
                            ),
                        loading: () => const CircularProgressIndicator(),
                        error:
                            (_, __) =>
                                const Text("ไม่สามารถโหลดข้อมูลกลุ่มสาระได้"),
                      ),

                      const SizedBox(height: 12),

                      /// Division
                      divisionsAsync.when(
                        data:
                            (items) => CustomDropdown(
                              label: "ฝ่ายงาน:",
                              value: selectedDivision,
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
                                  (val) =>
                                      setState(() => selectedDivision = val),
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

                      const SizedBox(height: 20),

                      CustomButton(
                        text: const Text(
                          "บันทึกข้อมูล",
                          style: TextStyle(color: Colors.white),
                        ),
                        border: 15,
                        color: Colors.blue,
                        onPressed:
                            () => showDialog(
                              context: context,
                              builder:
                                  (_) => AlertConfirmWidget(
                                    title:
                                        "คุณต้องการเปลี่ยนแปลงข้อมูลหรือไม่?",
                                    onConfirm: _saveUserHandler,
                                  ),
                            ),
                      ),
                    ],
                  ),
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
