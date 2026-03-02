import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/viewmodel/user_view_model.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

import '../../core/routes/app_routes.dart';

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
      ref.read(authProvider.notifier).refreshUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.value?.currentUser;
    final isUserDivisionBudget = user?.isBudget ?? false;

    ref.listen<AsyncValue<void>>(userProvider, (previous, next) {
      next.whenOrNull(
        error:
            (e, _) => _showSnackBar(context, "เกิดข้อผิดพลาด: $e", Colors.red),
        data: (_) {
          if (previous is AsyncLoading) {
            _showSnackBar(context, "ดำเนินการสำเร็จ", Colors.green);
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
              TitleNormal(title: "หน้าแรก", des: "สรุปผลเบื้องต้น"),

              if (isUserDivisionBudget) ...[
                _card(
                  context,
                  "คำขออนุมัติโครงการ",
                  6,
                  Colors.blue.shade50,
                  () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.budgetProjectRequest,
                    );
                  },
                ),
                _card(
                  context,
                  "ติดตามผลโครงการ",
                  6,
                  Colors.orange.shade50,
                  () {},
                ),
                _card(context, "สรุปโครงการ", 6, Colors.green.shade50, () {}),
              ],

              _card(context, "ยื่นโครงการใหม่", 1, Colors.blue.shade50, () {
                Navigator.pushNamed(context, AppRoutes.projectDraft);
              }),
              _card(
                context,
                "ติดตามโครงการของฉัน",
                2,
                Colors.orange.shade50,
                () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.projectPendingAndReject,
                  );
                },
              ),
              _card(
                context,
                "โครงการที่ต้องดำเนินการ",
                2,
                Colors.green.shade50,
                () {
                  Navigator.pushNamed(context, AppRoutes.projectApproved);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    String text,
    int num,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 1.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showSnackBar(
    BuildContext context,
    String text,
    Color color,
  ) {
    return ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
  }
}
