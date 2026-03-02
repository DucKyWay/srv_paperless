import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/screen_size.dart';
import '../../../viewmodel/auth_view_model.dart';
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
    final userId =
        ref.watch(authProvider.select((s) => s.value?.currentUser?.id)) ?? '';
    final width = context.screenWidth;
    final approvedProjects = ref.watch(approvedProjectsProvider);
    return MenuWidget(
      title: HeaderWithBackButton(),
      child: SafeArea(
        child: Center(
          child: Column(
            children: [
              TitleNormal(title: "ติดตามโครงการ"),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                  child: ProjectListViewWidget(
                    projectsAsync: approvedProjects,
                    emptyMessage: "ยังไม่มีรายการที่อนุมัติ",
                    routePath: AppRoutes.budgetProjectRequest,
                    onRefresh: () async {
                      ref.invalidate(approvedProjectsProvider);
                    },
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
