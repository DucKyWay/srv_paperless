import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/constants/project_status_enum.dart';
import 'package:srv_paperless/core/utils/project_status_ui_utils.dart';
import 'package:srv_paperless/widgets/in_app_browser.dart';

import '../../core/utils/date_util.dart';
import '../../core/utils/screen_size.dart';
import '../../data/minio.dart';
import '../../data/model/project_model.dart';
import '../../viewmodel/comment_view_model.dart';
import '../../viewmodel/projects/project_pdf_view_model.dart';
import 'card_widget.dart';

class ProjectDetailLookOnly extends ConsumerStatefulWidget {
  final Project project;
  const ProjectDetailLookOnly({super.key, required this.project});

  @override
  ConsumerState<ProjectDetailLookOnly> createState() =>
      _ProjectDetailLookOnlyState();
}

class _ProjectDetailLookOnlyState extends ConsumerState<ProjectDetailLookOnly> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.project.pdfPath != null &&
          widget.project.pdfPath!.isNotEmpty) {
        getPrivateFileUrl(widget.project.pdfPath!);
      }
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16, top: 16),
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
                  blurRadius: 15,
                  offset: const Offset(0, 8),
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
                      size: 140,
                      color: primaryColor.withOpacity(0.05),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.project.projectName!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(
                              widget.project.status,
                              primaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.person_rounded,
                          "ประธานโครงการ",
                          widget.project.chairman!,
                          primaryColor,
                        ),
                        _buildInfoRow(
                          Icons.account_balance_wallet_rounded,
                          "งบประมาณ",
                          "${widget.project.budget!.toStringAsFixed(2)} บาท",
                          primaryColor,
                        ),
                        _buildInfoRow(
                          Icons.event_note_rounded,
                          "วันที่เสนอโครงการ",
                          DateUtil.formatThaiDate(widget.project.date),
                          primaryColor,
                        ),
                        _buildInfoRow(
                          Icons.update_rounded,
                          "อัปเดตล่าสุด",
                          DateUtil.formatThaiDate(widget.project.fixLatest),
                          primaryColor,
                        ),
                        pdfAsync.when(
                          data:
                              (url) => InAppBrowserButton(
                                url: url,
                                color: primaryColor,
                                height: 32,
                              ),
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
                          error: (e, _) => const Text("ไม่พบเอกสาร"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ส่วนแสดงคอมเมนต์/หมายเหตุ
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 12),
            child: Text(
              "หมายเหตุ/ความคิดเห็น",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          commentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (err, stack) => Text("เกิดข้อผิดพลาดในการโหลดหมายเหตุ: $err"),
            data: (comments) {
              if (comments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
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
    );
  }

  Widget _buildStatusBadge(ProjectStatus? status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status?.label ?? "ไม่ระบุ",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
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
          Icon(icon, size: 18, color: color.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
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
