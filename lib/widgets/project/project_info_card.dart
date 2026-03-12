import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/constants/project_status_enum.dart';
import 'package:srv_paperless/core/utils/date_util.dart';
import 'package:srv_paperless/core/utils/project_status_ui_utils.dart';
import 'package:srv_paperless/data/model/project_model.dart';
import 'package:srv_paperless/widgets/in_app_browser.dart';

import '../../core/utils/screen_size.dart';
import '../../viewmodel/comment_view_model.dart';
import '../../viewmodel/projects/project_pdf_view_model.dart';
import '../../viewmodel/user_view_model.dart';
import 'card_widget.dart';

class ProjectInfoCard extends ConsumerStatefulWidget {
  final Project project;

  const ProjectInfoCard({super.key, required this.project});

  @override
  ConsumerState<ProjectInfoCard> createState() => _ProjectInfoCardState();
}

class _ProjectInfoCardState extends ConsumerState<ProjectInfoCard> {
  String? projectUserOwner;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (widget.project.userId.isEmpty) return;

    final user = await ref.read(userByIdProvider(widget.project.userId).future);

    if (!mounted) return;

    setState(() {
      projectUserOwner = user?.fullname ?? "ไม่ระบุ";
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final primaryColor = widget.project.status.mainColor;
    final bgColor = widget.project.status.backgroundColor;
    final commentsAsync = ref.watch(commentsByProjectId(widget.project.id));

    final pdfAsync = ref.watch(
      projectPdfUrlProvider(widget.project.pdfPath ?? ""),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: width * 0.08),
          width: double.infinity,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    widget.project.status.icon,
                    size: 150,
                    color: primaryColor.withOpacity(0.05),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.project.projectName ??
                                  "ไม่ระบุชื่อโครงการ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          _buildStatusBadge(
                            widget.project.status,
                            primaryColor,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),

                      _buildInfoRow(
                        Icons.person_pin_outlined,
                        "ประธานโครงการ",
                        widget.project.chairman ?? "ไม่ระบุ",
                        primaryColor,
                      ),

                      _buildInfoRow(
                        Icons.person_outline,
                        "ผู้ยื่นโครงการ",
                        projectUserOwner ?? "กำลังโหลด...",
                        primaryColor,
                      ),

                      _buildInfoRow(
                        Icons.payments_outlined,
                        "งบประมาณ",
                        "${widget.project.budget?.toStringAsFixed(2) ?? '0.00'} บาท",
                        primaryColor,
                      ),

                      _buildInfoRow(
                        Icons.calendar_today_outlined,
                        "ยื่นเสนอเมื่อ",
                        DateUtil.formatThaiDate(widget.project.date),
                        primaryColor,
                      ),

                      _buildInfoRow(
                        Icons.history_outlined,
                        "แก้ไขล่าสุด",
                        DateUtil.formatThaiDate(widget.project.fixLatest),
                        primaryColor,
                      ),

                      const SizedBox(height: 12),

                      /// PDF BUTTON
                      pdfAsync.when(
                        data: (url) {
                          if (url == null || url.isEmpty) {
                            return const Text(
                              "ไม่พบเอกสาร",
                              style: TextStyle(color: Colors.red),
                            );
                          }

                          return InAppBrowserButton(
                            url: url,
                            color: primaryColor,
                            height: 32,
                          );
                        },
                        loading:
                            () => const SizedBox(
                              height: 32,
                              child: Center(
                                child: SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                        error:
                            (_, __) => const Text(
                              "ไม่พบเอกสาร",
                              style: TextStyle(color: Colors.red),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ส่วนแสดงคอมเมนต์/หมายเหตุ
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: Column(
            children: [
              Text(
                "หมายเหตุ/ความคิดเห็น",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              commentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (err, stack) =>
                        Text("เกิดข้อผิดพลาดในการโหลดหมายเหตุ: $err"),
                data: (comments) {
                  if (comments.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: width * 0.08,
                      ),
                      child: Text(
                        "ไม่มีหมายเหตุเพิ่มเติม",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder:
                        (context, index) =>
                            CommentCardWidget(comment: comments[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ProjectStatus? status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status?.label ?? "ไม่ทราบสถานะ",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: color.withOpacity(0.6)),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
