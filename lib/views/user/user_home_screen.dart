import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/viewmodel/user_view_model.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

import '../../core/routes/app_routes.dart';
import '../../core/utils/snackbar_util.dart';
import '../../viewmodel/project_view_model.dart';

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

    final approvedCount = ref.watch(approvedProjectsCount).value ?? 0;
    final startedCount = ref.watch(startedProjectsCount).value ?? 0;
    final pendingCount = ref.watch(pendingProjectsCount).value ?? 0;
    final rejectCount = ref.watch(rejectProjectsCount).value ?? 0;
    final finishedCount = ref.watch(finishedProjectsCount).value ?? 0;

    ref.listen<AsyncValue<void>>(userProvider, (previous, next) {
      next.whenOrNull(
        error: (e, _) => SnackBarWidget.error(context, "เกิดข้อผิดพลาด: $e"),
        data: (_) {
          if (previous is AsyncLoading) {
            SnackBarWidget.success(context, "ดำเนินการสำเร็จ");
          }
        },
      );
    });

    return MenuWidget(
      title: const HeaderNormal(),
      child: Container(
        decoration: BoxDecoration(color: Colors.grey[50]),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              const TitleNormal(title: "หน้าแรก", des: "สรุปผลการดำเนินงาน"),
              const SizedBox(height: 12),

              _highlightCard(
                context,
                "ยื่นโครงการใหม่",
                "สร้างและบันทึกร่างโครงการของคุณ",
                Icons.add_circle_rounded,
                const Color(0xff3A9AB5),
                () => Navigator.pushNamed(context, AppRoutes.projectDraft),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    if (isUserDivisionBudget)
                      _statusCard(
                        context,
                        "คำขออนุมัติโครงการ",
                        pendingCount,
                        Icons.pending_actions_outlined,
                        Colors.purple,
                        () => Navigator.pushNamed(
                          context,
                          AppRoutes.budgetProjectRequest,
                        ),
                      ),

                    _statusCard(
                      context,
                      "ติดตามโครงการ",
                      pendingCount + rejectCount,
                      Icons.track_changes_outlined,
                      Colors.orange,
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.projectPendingAndReject,
                      ),
                    ),

                    _statusCard(
                      context,
                      "โครงการที่ต้องดำเนินการ",
                      approvedCount + startedCount,
                      Icons.play_lesson_outlined,
                      Colors.blueAccent,
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.projectApproved,
                      ),
                    ),

                    _statusCard(
                      context,
                      "โครงการที่ดำเนินเสร็จสิ้น",
                      finishedCount,
                      Icons.task_alt_outlined,
                      Colors.green,
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.projectFinished,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _highlightCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(
    BuildContext context,
    String text,
    int num,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                num.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
