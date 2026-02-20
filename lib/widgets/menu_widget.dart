import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/repositories/user_repo.dart';
import 'package:srv_paperless/services/auth_service.dart';
import 'package:srv_paperless/viewmodel/user_view_model.dart';

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
              ListTile(
                leading: const Icon(Icons.add_business_outlined),
                title: const Text("ยื่นโครงการใหม่"),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.projectDraft, arguments: "create");
                },
              ),
              ListTile(
                leading: const Icon(Icons.my_library_books_outlined),
                title: const Text("โครงการของฉัน"),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.projectDraft);
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text("โปรไฟล์"),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.userProfile);
                },
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "ออกจากระบบ",
                  style: TextStyle(color: Color.fromRGBO(244, 67, 54, 1)),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(authServiceProvider).logout();
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
