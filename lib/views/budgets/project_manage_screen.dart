import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/routes/app_routes.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/viewmodel/project_view_model.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

import '../../widgets/project/card_widget.dart';

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

    if (!isUserDivisionBudget) Navigator.pop(context);

    return MenuWidget(
      title: HeaderWithBackButton(),
      child: Column(
        children: [
          const TitleNormal(title: "คำขออนุมัติโครงการ"),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: pendingRequest(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

Widget pendingRequest(BuildContext context, WidgetRef ref) {
  final pendingProjects = ref.watch(pendingProjectsProvider);

  return pendingProjects.when(
    data: (projects) {
      if (projects.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text("ไม่พบโครงการ", style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }
      return ListView.builder(
        itemCount: projects.length,
        itemBuilder:
            (context, index) => ProjectCardDetail(
              project: projects[index],
              routes: AppRoutes.budgetProjectRequest,
            ),
      );
    },
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) => Center(child: Text("เกิดข้อผิดพลาด $err")),
  );
}
