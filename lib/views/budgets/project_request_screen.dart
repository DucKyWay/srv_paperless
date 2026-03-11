import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/constants/project_status_enum.dart';
import 'package:srv_paperless/core/utils/date_util.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:srv_paperless/data/minio.dart';
import 'package:srv_paperless/data/model/project_model.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/viewmodel/comment_view_model.dart';
import 'package:srv_paperless/viewmodel/project_view_model.dart';
import 'package:srv_paperless/widgets/alert_confirm_widget.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:srv_paperless/widgets/in_app_browser.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

import '../../core/utils/snackbar_util.dart';
import '../../data/model/comment_model.dart';
import '../../viewmodel/user_view_model.dart';
import '../../widgets/project/card_widget.dart';
import '../../widgets/project/project_info_card.dart';

class ProjectRequestScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectRequestScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectRequestScreen> createState() =>
      _ProjectRequestScreenState();
}

class _ProjectRequestScreenState extends ConsumerState<ProjectRequestScreen> {
  Project? project;
  String? pdfUrl;

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

    String? url;
    if (projectData.pdfPath != null && projectData.pdfPath!.isNotEmpty) {
      url = await getPrivateFileUrl(projectData.pdfPath!);
    }

    if (mounted) {
      setState(() {
        project = projectData;
        pdfUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (project == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final width = context.screenWidth;

    return MenuWidget(
      title: HeaderWithBackButton(),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            TitleNormal(title: "คำขออนุมัติโครงการ"),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: ProjectInfoCard(project: project!),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: _projectComments(context, ref),
            ),

            const SizedBox(height: 8),
            if (project!.status == ProjectStatus.pending) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton(
                      text: Text(
                        "อนุมัติโครงการ",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.green.shade700,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertConfirmWidget(
                                title: "คุณต้องการอนุมัติโครงการนี้หรือไม่",
                                color: Colors.green.shade50,
                                onConfirm: () {
                                  ref
                                      .watch(projectProvider.notifier)
                                      .updateProjectStatus(
                                        widget.projectId,
                                        ProjectStatus.approve,
                                      );
                                  Navigator.pop(context);
                                  SnackBarWidget.success(
                                    context,
                                    "อนุมัติโครงการ ${project!.projectName}",
                                  );
                                },
                              ),
                        );
                      },
                    ),
                    SizedBox(height: 12),
                    CustomButton(
                      text: Text(
                        "หมายเหตุ",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.yellow.shade700,
                      onPressed: () => _showCommentDialog(context, ref),
                    ),
                    SizedBox(height: 12),
                    CustomButton(
                      text: Text(
                        "ปฏิเสธโครงการ",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.red.shade700,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertConfirmWidget(
                                title: "คุณต้องการปฏิเสธโครงการนี้หรือไม่",
                                color: Colors.red.shade50,
                                onConfirm: () {
                                  ref
                                      .watch(projectProvider.notifier)
                                      .updateProjectStatus(
                                        widget.projectId,
                                        ProjectStatus.rejected,
                                      );

                                  Navigator.pop(context);
                                  SnackBarWidget.success(
                                    context,
                                    "ปฏิเสธโครงการ ${project!.projectName} แล้ว",
                                  );
                                },
                              ),
                        );
                      },
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _projectComments(BuildContext context, WidgetRef ref) {
    final latestCommentData = ref.watch(latestCommentByProjectId(project!.id));

    return latestCommentData.when(
      data: (comment) {
        if (comment == null) {
          return const SizedBox.shrink();
        }
        return CommentCardWidget(comment: comment);
      },
      loading: () {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (err, stack) {
        return Center(child: Text("เกิดข้อผิดพลาดในการแสดงหมายเหตุ: $err"));
      },
    );
  }

  void _showCommentDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: context.screenWidth * 0.85,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 4),
                    const Text(
                      "หมายเหตุทั้งหมด",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: context.screenHeight * 0.5,
                      ),
                      child: _commentCard(context, ref),
                    ),

                    const SizedBox(height: 16),

                    CustomButton(
                      text: const Text(
                        "เพิ่มหมายเหตุใหม่",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blue,
                      onPressed: () {
                        _showAddCommentDialog(context, ref);
                      },
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      text: const Text(
                        "ออก",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.red,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _commentCard(BuildContext context, WidgetRef ref) {
    final commentData = ref.watch(commentsByProjectId(widget.projectId));

    return commentData.when(
      data: (comments) {
        if (comments.isEmpty) {
          SnackBarWidget.warning(context, "ยังไม่มีหมายเหตุ");
          return const Center(child: Text("ยังไม่มีหมายเหตุ"));
        }
        debugPrint(
          "Comments for ${widget.projectId} count: ${comments.length}",
        );

        return ListView.separated(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) => _commentItem(comments[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        );
      },
      loading: () {
        print("DEBUG: Comments are loading for ID: ${widget.projectId}");
        return const Center(child: CircularProgressIndicator());
      },
      error: (err, stack) {
        print("DEBUG: Error loading comments: $err");
        print(stack);
        SnackBarWidget.error(context, "เกิดข้อผิดพลาดในการแสดงหมายเหตุ");
        return Center(child: Text("เกิดข้อผิดพลาด: $err"));
      },
    );
  }

  void _showAddCommentDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("เพิ่มหมายเหตุ"),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "กรอกหมายเหตุ",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            CancelAndConfirmRowWidget(
              onConfirm: () async {
                final message = controller.text.trim();
                if (message.isEmpty) return;

                final authState = ref.read(authProvider).value;
                final userId = authState?.currentUser?.id;

                await ref
                    .read(commentProvider.notifier)
                    .createComment(userId!, project!.id, message);

                Navigator.pop(context);
                SnackBarWidget.success(context, "เพิ่มหมายเหตุสำเร็จ");
              },
            ),
          ],
        );
      },
    );
  }

  Widget _commentItem(Comment comment) {
    final userAsync = ref.watch(userByIdProvider(comment.userId));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userAsync.when(
            data:
                (user) => Text(
                  "ผู้ลงหมายเหตุ: ${user?.fullname ?? "ไม่พบผู้ใช้"}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
            loading:
                () => const Text(
                  "กำลังโหลดชื่อผู้ใช้...",
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
            error:
                (_, __) => const Text(
                  "ไม่พบผู้ใช้",
                  style: TextStyle(color: Colors.red),
                ),
          ),
          const SizedBox(height: 6),
          Text("หมายเหตุ: ${comment.message}"),
          const Divider(),
          Text(
            "วันที่: ${DateUtil.formatThaiDate(comment.commentCreatedAt)}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
