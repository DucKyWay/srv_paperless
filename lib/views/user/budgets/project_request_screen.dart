import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/utils/date_util.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:srv_paperless/data/minio.dart';
import 'package:srv_paperless/data/model/comment_model.dart';
import 'package:srv_paperless/data/model/project_model.dart';
import 'package:srv_paperless/viewmodel/comment_view_model.dart';
import 'package:srv_paperless/viewmodel/project_view_model.dart';
import 'package:srv_paperless/viewmodel/user_view_model.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

import '../../../widgets/project/card_widget.dart';

class ProjectRequestScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectRequestScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectRequestScreen> createState() =>
      _ProjectRequestScreenState();
}

class _ProjectRequestScreenState extends ConsumerState<ProjectRequestScreen> {
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
      title: HeaderWithBackButton(),
      child: Center(
        child: Column(
          children: [
            TitleNormal(title: "คำขออนุมัติโครงการ"),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 1.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "ชื่อโครงการ: ${project!.projectName}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "ประธานโครงการ : ${project!.chairman}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "จำนวนเงินในโครงการ : ${project!.budget}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "เสนอโครงการ : ${DateUtil.formatThaiDate(project!.date)}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "อนุมัติโครงการ : ${project!.status.label}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "แก้ไขล่าสุด : ${DateUtil.formatThaiDate(project!.fixLatest)}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                child: _projectComments(context, ref),
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