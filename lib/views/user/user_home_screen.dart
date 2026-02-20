import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/viewmodel/user_view_model.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';

class UserHomePage extends ConsumerStatefulWidget {
  const UserHomePage({super.key});

  @override
  ConsumerState<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends ConsumerState<UserHomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authProvider.notifier).getCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;

    ref.listen<AsyncValue<void>>(userProvider, (previous, next) {
      next.whenOrNull(
        error:
            (e, _) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("เกิดข้อผิดพลาด: $e"),
                backgroundColor: Colors.red,
              ),
            ),
        data: (_) {
          if (previous is AsyncLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("ดำเนินการสำเร็จ"),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    });

    return MenuWidget(
      title: HeaderNormal(),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/srv-logo.png",
                      fit: BoxFit.contain,
                    ),
                    Text(
                      "หน้าแรก",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("สรุปผลเบื้องต้น", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),

              if (user?.isBudget == true) ...[
                card(context, "คำขออนุมัติโครงการ", 6, () {}),
                card(context, "ติดตามผลโครงการ", 6, () {}),
                card(context, "สรุปโครงการที่ดำเนินการสำเร็จ", 6, () {}),
              ],

              card(context, "ยื่นโครงการ", 1, () {
                Navigator.pushNamed(context, "/request/draft");
              }),
              card(context, "ติดตามโครงการ", 2, () {}),
              card(context, "สรุปโครงการที่ดำเนินการสำเร็จ", 3, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget card(BuildContext context, String text, int num, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.5),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 1.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$num',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
