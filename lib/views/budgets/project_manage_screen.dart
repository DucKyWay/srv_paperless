import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/routes/app_routes.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/viewmodel/project_view_model.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

import '../../widgets/project/project_list_view_widget.dart';

class ProjectManageScreen extends ConsumerStatefulWidget {
  const ProjectManageScreen({super.key});

  @override
  ConsumerState<ProjectManageScreen> createState() =>
      _ProjectManageScreenState();
}

class _ProjectManageScreenState extends ConsumerState<ProjectManageScreen> {
  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final authState = ref.watch(authProvider);
    final isUserDivisionBudget =
        authState.value?.currentUser?.isBudget ?? false;

    if (!isUserDivisionBudget) {
      Future.microtask(() => Navigator.pop(context));
    }

    final pendingProject = ref.watch(pendingProjectsProvider);
    final approvedProject = ref.watch(approvedProjectsProvider);
    final rejectedProject = ref.watch(rejectedProjectsProvider);

    return DefaultTabController(
      length: 3,
      child: MenuWidget(
        title: const HeaderWithBackButton(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleNormal(
                      title: "จัดการคำขออนุมัติ",
                      des: "ตรวจสอบและดำเนินการอนุมัติโครงการที่เสนอมา",
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: width * 0.08),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hourglass_empty_rounded, size: 18),
                          SizedBox(width: 2),
                          Text("รออนุมัติ"),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 18),
                          SizedBox(width: 2),
                          Text("อนุมัติแล้ว"),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 18),
                          SizedBox(width: 2),
                          Text("ปฏิเสธ"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      ProjectListViewWidget(
                        projectsAsync: pendingProject,
                        emptyMessage: "ไม่มีรายการที่รออนุมัติในขณะนี้",
                        routePath: AppRoutes.budgetProjectRequest,
                        onRefresh: () async {
                          ref.invalidate(pendingProjectsProvider);
                        },
                      ),
                      ProjectListViewWidget(
                        projectsAsync: approvedProject,
                        emptyMessage: "ยังไม่มีรายการที่อนุมัติแล้ว",
                        routePath: AppRoutes.budgetProjectRequest,
                        onRefresh: () async {
                          ref.invalidate(approvedProjectsProvider);
                        },
                      ),
                      ProjectListViewWidget(
                        projectsAsync: rejectedProject,
                        emptyMessage: "ยังไม่มีรายการที่ปฏิเสธ",
                        routePath: AppRoutes.budgetProjectRequest,
                        onRefresh: () async {
                          ref.invalidate(rejectedProjectsProvider);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
