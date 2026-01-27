import 'package:flutter/material.dart';
import 'package:srv_paperless/views/widgets/main_layout.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "หน้าหลัก",
      child: Center(child: Text("ยินดีต้อนรับ")),
    );
  }
}