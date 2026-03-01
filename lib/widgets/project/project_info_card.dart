import 'package:flutter/material.dart';
import 'package:srv_paperless/core/constants/project_status_enum.dart';
import 'package:srv_paperless/core/utils/date_util.dart';
import 'package:srv_paperless/data/model/project_model.dart';

class ProjectInfoCard extends StatelessWidget {
  final Project project;

  const ProjectInfoCard({super.key, required this.project});

  Color _getStatusColor(ProjectStatus? status) {
    switch (status) {
      case ProjectStatus.draft:
        return Colors.blue.shade50;
      case ProjectStatus.pending:
        return Colors.orange.shade50;
      case ProjectStatus.approve:
        return Colors.green.shade50;
      case ProjectStatus.started:
        return Colors.purple.shade50; // เพิ่มสีม่วงสำหรับเริ่มโครงการ
      case ProjectStatus.rejected:
        return Colors.red.shade50;
      default:
        return Colors.white;
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
        return Colors.purple.shade700; // เพิ่มสีม่วงสำหรับเริ่มโครงการ
      case ProjectStatus.rejected:
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getPrimaryColor(project.status);
    final bgColor = _getStatusColor(project.status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
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
                _getStatusIcon(project.status),
                size: 150,
                color: primaryColor.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          project.projectName!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      _buildStatusBadge(project.status, primaryColor),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  _buildInfoRow(Icons.person_outline, "ประธานโครงการ", project.chairman!, primaryColor),
                  _buildInfoRow(Icons.payments_outlined, "งบประมาณ", "${project.budget!.toStringAsFixed(2)} บาท", primaryColor),
                  _buildInfoRow(Icons.calendar_today_outlined, "ยื่นเสนอเมื่อ", DateUtil.formatThaiDate(project.date), primaryColor),
                  _buildInfoRow(Icons.history_outlined, "แก้ไขล่าสุด", DateUtil.formatThaiDate(project.fixLatest), primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
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
        children: [
          Icon(icon, size: 20, color: color.withOpacity(0.7)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.6),
                ),
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
        ],
      ),
    );
  }

  IconData _getStatusIcon(ProjectStatus? status) {
    switch (status) {
      case ProjectStatus.draft: return Icons.edit_document;
      case ProjectStatus.pending: return Icons.hourglass_empty;
      case ProjectStatus.approve: return Icons.check_circle_outline;
      case ProjectStatus.started: return Icons.play_circle_outline; // เพิ่มไอคอนสำหรับเริ่มโครงการ
      case ProjectStatus.rejected: return Icons.cancel_outlined;
      default: return Icons.info_outline;
    }
  }
}
