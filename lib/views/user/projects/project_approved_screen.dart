import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/screen_size.dart';
import '../../../viewmodel/project_view_model.dart';
import '../../../widgets/menu_header_widget.dart';
import '../../../widgets/project/project_list_view_widget.dart';
import '../../../widgets/title_widget.dart';

class ProjectApproved extends ConsumerStatefulWidget {
  const ProjectApproved({super.key});

  @override
  ConsumerState<ProjectApproved> createState() => _ProjectApprovedState();
}

class _ProjectApprovedState extends ConsumerState<ProjectApproved> {
  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final approvedProjects = ref.watch(approvedProjectsProvider);
    final startedProjects = ref.watch(startedProjectsProvider);

    return DefaultTabController(
      length: 2,
      child: MenuWidget(
        title: const HeaderWithBackButton(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ติดตามโครงการ",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ) ??
                          const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ตรวจสอบโครงการที่ได้รับการอนุมัติและเริ่มดำเนินการ",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: width * 0.08),
                padding: const EdgeInsets.all(6),
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
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 18),
                          SizedBox(width: 8),
                          Text("อนุมัติแล้ว"),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_outline, size: 18),
                          SizedBox(width: 8),
                          Text("เริ่มโครงการ"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      ProjectListViewWidget(
                        projectsAsync: approvedProjects,
                        emptyMessage: "ยังไม่มีรายการที่อนุมัติ",
                        routePath: AppRoutes.projectApprovedSubmit,
                        onRefresh: () async {
                          ref.invalidate(approvedProjectsProvider);
                        },
                      ),
                      ProjectListViewWidget(
                        projectsAsync: startedProjects,
                        emptyMessage: "ยังไม่มีโครงการที่เริ่มดำเนินการ",
                        routePath: AppRoutes.projectApprovedSubmit, // สามารถเปลี่ยน route ได้ตามต้องการ
                        onRefresh: () async {
                          ref.invalidate(startedProjectsProvider);
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
