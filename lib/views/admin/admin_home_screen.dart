import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/views/admin/admin_manage_data_screen.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

import '../../core/routes/app_routes.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MenuWidget(
      title: HeaderWithBackButton(),
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TitleNormal(des: "การตั้งค่าสำหรับผู้ดูแลระบบ"),
              _card(
                context,
                "จัดการผู้ใช้งาน",
                AppRoutes.adminManageUsers,
                null,
                Colors.blue.shade700,
              ),
              _card(
                context,
                "จัดการฝ่ายงาน",
                AppRoutes.adminManageData,
                ConfigMode.divisions,
                Colors.blue.shade700,
              ),
              _card(
                context,
                "จัดการกลุ่มสาระการเรียนรู้",
                AppRoutes.adminManageData,
                ConfigMode.academicDepartment,
                Colors.blue.shade700,
              ),
              _card(
                context,
                "จัดการตำแหน่งงาน",
                AppRoutes.adminManageData,
                ConfigMode.employeeStatus,
                Colors.blue.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    String label,
    String routes,
    ConfigMode? param,
    Color buttonColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black45, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          CustomButton(
            width: 100,
            height: 45,
            text: const Text("จัดการ", style: TextStyle(color: Colors.white)),
            border: 15,
            color: buttonColor,
            onPressed:
                () => Navigator.pushNamed(context, routes, arguments: param),
          ),
        ],
      ),
    );
  }
}
