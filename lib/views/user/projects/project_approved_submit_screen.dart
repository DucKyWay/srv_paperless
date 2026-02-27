import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_size.dart';
import '../../../data/model/project_model.dart';
import '../../../viewmodel/comment_view_model.dart';
import '../../../viewmodel/project_view_model.dart';
import '../../../widgets/alert_confirm_widget.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/menu_header_widget.dart';
import '../../../widgets/menu_widget.dart';
import '../../../widgets/project/card_widget.dart';
import '../../../widgets/project/project_info_card.dart';
import '../../../widgets/title_widget.dart';

class ProjectApprovedSubmitScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectApprovedSubmitScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectApprovedSubmitScreen> createState() => _ProjectApprovedSubmitScreenState();
}

class _ProjectApprovedSubmitScreenState extends ConsumerState<ProjectApprovedSubmitScreen> {
  Project? project;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final projectData = await ref.read(
      projectByIdProvider(widget.projectId).future,
    );
    if (projectData == null) return;
    setState(() {
      project = projectData;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (project == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final width = context.screenWidth;

    return MenuWidget(
      title: const HeaderWithBackButton(),
      child: Center(
        child: Column(
          children: [
            const TitleNormal(title: "คำขออนุมัติโครงการ"),
            ProjectInfoCard(project: project!),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                child: _projectComments(context, ref),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomButton(
                height: 55,
                text: const Text(
                  "เริ่มโครงการ",
                  style: TextStyle(color: Colors.white),
                ),
                border: 15,
                color: Theme.of(context).colorScheme.primaryContainer,
                onPressed:
                    () => showDialog(
                  context: context,
                  builder:
                      (_) => AlertConfirmWidget(
                    title:
                    "คุณต้องการเริ่มโครงการหรือไม่",
                    onConfirm:
                        (){},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _projectComments(BuildContext context, WidgetRef ref) {
    final commentsData = ref.watch(commentByProjectId(project!.id));

    return commentsData.when(
      data: (comments) {
        if (comments.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.builder(
          itemCount: comments.length,
          itemBuilder:
              (context, index) => CommentCardWidget(comment: comments[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (err, stack) =>
          Center(child: Text("เกิดข้อผิดพลาดในการแสดงหมายเหตุ $err")),
    );
  }
}
