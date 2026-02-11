import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;
  final Widget title;

  const MainLayout({super.key, required this.child, required this.title});

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
                    Navigator.pushNamed(context, '/user_home');
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text("โปรไฟล์"),
                onTap: () {
                    Navigator.pushNamed(context, '/user_profile');
                },
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "ออกจากระบบ",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
              const SizedBox(height: 10), // เว้นระยะห่างจากขอบล่างนิดหน่อย
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}
