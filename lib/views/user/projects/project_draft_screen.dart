import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/routes/app_routes.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/viewmodel/project_view_model.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/project/project_list_view_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

class RequestDraftScreen extends ConsumerStatefulWidget {
  const RequestDraftScreen({super.key});

  @override
  ConsumerState<RequestDraftScreen> createState() =>
      _RequestDraftScreenState();
}

class _RequestDraftScreenState extends ConsumerState<RequestDraftScreen> {
  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    
    // ใช้ select เพื่อฟังเฉพาะ userId เท่านั้น ป้องกันการ reload บ่อยเกินไป
    final userId = ref.watch(authProvider.select((s) => s.currentUser?.id)) ?? '';
    final draftProjects = ref.watch(draftProjectsProvider(userId));

    return MenuWidget(
      title: const HeaderWithBackButton(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.projectCreate,
              arguments: 'create');
        },
        backgroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            children: [
              const TitleNormal(title: "ร่างโครงการของฉัน"),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                  child: ProjectListViewWidget(
                    projectsAsync: draftProjects,
                    emptyMessage: "คุณยังไม่มีรายการฉบับร่าง",
                    routePath: AppRoutes.projectDraft,
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
