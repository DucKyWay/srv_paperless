import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';

import '../core/routes/app_routes.dart';

class MenuWidget extends ConsumerWidget {
  final Widget child;
  final Widget title;
  final Widget? floatingActionButton;

  const MenuWidget({
    super.key,
    required this.child,
    required this.title,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.currentUser;
    final isUserDivisionBudget = currentUser?.isBudget ?? false;
    final isUserRoleAdmin = currentUser?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: title,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 50),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text("หน้าแรก"),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.userHome);
                },
              ),
              if(isUserDivisionBudget)...[
                ListTile(
                  leading: const Icon(Icons.book_outlined),
                  title: const Text("จัดการโครงการ"),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.projectRequest),
                )
              ],
              ListTile(
                leading: const Icon(Icons.add_business_outlined),
                title: const Text("ยื่นโครงการใหม่"),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.projectCreate);
                },
              ),
              ListTile(
                leading: const Icon(Icons.my_library_books_outlined),
                title: const Text("ร่างโครงการของฉัน"),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.projectDraft);
                },
              ),
              if(isUserRoleAdmin)...[
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text("ตั้งค่าผู้ดูแล"),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.adminHome);
                  },
                )
              ],
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text("แก้ไขข้อมูลส่วนตัว"),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.userProfile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "ออกจากระบบ",
                  style: TextStyle(color: Color.fromRGBO(244, 67, 54, 1)),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}
