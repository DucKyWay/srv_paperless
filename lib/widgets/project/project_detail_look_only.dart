import 'package:flutter/material.dart';
import 'package:srv_paperless/core/constants/project_status_enum.dart';

import '../../core/utils/date_util.dart';
import '../../core/utils/screen_size.dart';
import '../../data/model/project_model.dart';

class ProjectDetailLookOnly extends StatelessWidget {
  final Project project;
  const ProjectDetailLookOnly({super.key, required this.project});

  Color _getStatusColor(ProjectStatus? status) {
    switch (status) {
      case ProjectStatus.draft:
        return Colors.blue.shade50;
      case ProjectStatus.pending:
        return Colors.orange.shade50;
      case ProjectStatus.approve:
        return Colors.green.shade50;
      case ProjectStatus.started:
        return Colors.purple.shade50;
      case ProjectStatus.finished:
        return Colors.teal.shade50;
      case ProjectStatus.rejected:
        return Colors.red.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getPrimaryColor(ProjectStatus? status) {
    switch (status) {
      case ProjectStatus.draft:
        return Colors.blue.shade700;
      case ProjectStatus.pending:
        return Colors.orange.shade700;
      case ProjectStatus.approve:
        return Colors.green.shade700;
      case ProjectStatus.started:
        return Colors.purple.shade700;
      case ProjectStatus.finished:
        return Colors.teal.shade700;
      case ProjectStatus.rejected:
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getStatusIcon(ProjectStatus? status) {
    switch (status) {
      case ProjectStatus.draft:
        return Icons.edit_note_rounded;
      case ProjectStatus.pending:
        return Icons.hourglass_empty_rounded;
      case ProjectStatus.approve:
        return Icons.check_circle_outline_rounded;
      case ProjectStatus.started:
        return Icons.play_circle_outline_rounded;
      case ProjectStatus.finished:
        return Icons.task_alt_rounded;
      case ProjectStatus.rejected:
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final primaryColor = _getPrimaryColor(project.status);
    final bgColor = _getStatusColor(project.status);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, top: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
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
                  _getStatusIcon(project.status),
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
                            project.projectName!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(project.status, primaryColor),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    _buildInfoRow(
                      Icons.person_rounded,
                      "ประธานโครงการ",
                      project.chairman!,
                      primaryColor,
                    ),
                    _buildInfoRow(
                      Icons.account_balance_wallet_rounded,
                      "งบประมาณ",
                      "${project.budget!.toStringAsFixed(2)} บาท",
                      primaryColor,
                    ),
                    _buildInfoRow(
                      Icons.event_note_rounded,
                      "วันที่เสนอโครงการ",
                      DateUtil.formatThaiDate(project.date),
                      primaryColor,
                    ),
                    _buildInfoRow(
                      Icons.update_rounded,
                      "อัปเดตล่าสุด",
                      DateUtil.formatThaiDate(project.fixLatest),
                      primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

class ProjectCard extends StatelessWidget {
  final Project project;
  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "ชื่อโครงการ: ${project.projectName}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "ประธานโครงการ : ${project.chairman}",
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "จำนวนเงินในโครงการ : ${project.budget}",
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "เสนอโครงการ : ${DateUtil.formatThaiDate(project.date)}",
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "สถานะโครงการ : ${project.status.label}",
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "แก้ไขล่าสุด : ${DateUtil.formatThaiDate(project.fixLatest)}",
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
