import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:srv_paperless/core/routes/app_routes.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:srv_paperless/data/model/project_model.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/viewmodel/project_view_model.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

import '../../../widgets/project/card_widget.dart';

class RequestDraftAndPendingScreen extends ConsumerStatefulWidget {
  const RequestDraftAndPendingScreen({super.key});

  @override
  ConsumerState<RequestDraftAndPendingScreen> createState() =>
      _RequestDraftAndPendingScreenState();
}

class _RequestDraftAndPendingScreenState
    extends ConsumerState<RequestDraftAndPendingScreen> {
  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    return MenuWidget(
      title: const HeaderWithBackButton(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.projectCreate, arguments: 'create');
        },
        backgroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: SafeArea(
        child: Center(
          // ในเมธอด build
          child: Column(
            children: [
              const TitleNormal(title: "ร่างโครงการของฉัน"),
              // ใช้ Expanded ครอบ เพื่อให้ ListView มีขอบเขตความสูงที่ชัดเจน
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                  child: draftRequest(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget draftRequest(BuildContext context, WidgetRef ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.currentUser?.id ?? '';
  final draftProjects = ref.watch(draftProjectsProvider(userId));
  return draftProjects.when(
    data: (projects) {
      if (projects.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "คุณยังไม่มีรายการฉบับร่าง",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) => ProjectCardDetail(project: projects[index], routes: AppRoutes.projectDraft,),
      );
    },
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) => Center(child: Text("เกิดข้อผิดพลาด: $err")),
  );
}