import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/constants/project_status_enum.dart';
import 'package:srv_paperless/core/utils/date_util.dart';
import 'package:srv_paperless/data/model/comment_model.dart';
import 'package:srv_paperless/data/model/project_model.dart';

import '../../data/minio.dart';
import '../../viewmodel/user_view_model.dart';

abstract class ProjectCardWidget extends ConsumerWidget {
  const ProjectCardWidget({super.key});

  Widget buildLeading(BuildContext context, WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return buildLeading(context, ref);
  }
}

class ProjectCardDetail extends ProjectCardWidget {
  final Project project;
  final String routes;

  const ProjectCardDetail({
    super.key,
    required this.project,
    required this.routes,
  });

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
        return Colors.white;
    }
  }

  Color _getBorderColor(ProjectStatus? status) {
    switch (status) {
      case ProjectStatus.draft:
        return Colors.blue.shade300;
      case ProjectStatus.pending:
        return Colors.orange.shade300;
      case ProjectStatus.approve:
        return Colors.green.shade300;
      case ProjectStatus.started:
        return Colors.purple.shade300;
      case ProjectStatus.finished:
        return Colors.teal.shade300;
      case ProjectStatus.rejected:
        return Colors.red.shade300;
      default:
        return Colors.black12;
    }
  }

  @override
  Widget buildLeading(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(project.userId));

    return userAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (user) {
        final borderColor = _getBorderColor(project.status);
        final bgColor = _getStatusColor(project.status);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              FutureBuilder<String>(
                future: getPrivateFileUrl(user?.image ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue.shade50,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  final imageUrl = snapshot.data;

                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        imageUrl ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "assets/images/user.png",
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            project.projectName!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black.withValues(alpha: 0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(project.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildInfoText(Icons.person_outline, user?.fullname ?? 'ไม่ระบุ'),
                    _buildInfoText(Icons.calendar_today_outlined, DateUtil.formatThaiDate(project.date)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            routes,
                            arguments: project.id,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: borderColor,
                          side: BorderSide(color: borderColor, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "รายละเอียด",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(ProjectStatus? status) {
    final color = _getBorderColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status?.label ?? '',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class CommentCardWidget extends ProjectCardWidget {
  final Comment comment;

  const CommentCardWidget({super.key, required this.comment});

  @override
  Widget buildLeading(BuildContext context, WidgetRef ref) {
    final userByIdAsync = ref.watch(userByIdProvider(comment.userId));

    return userByIdAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (commentor) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.fromLTRB(12, 12, 20, 16),
          decoration: BoxDecoration(
            color: const Color(0xffFFF1F0),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade100, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade900.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<String>(
                future: getPrivateFileUrl(commentor?.image ?? ''),
                builder: (context, snapshot) {
                  final imageUrl = snapshot.data;
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: imageUrl != null
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : Image.asset("assets/images/user.png", fit: BoxFit.cover),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          commentor?.fullname ?? 'ไม่ทราบชื่อ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "หมายเหตุ",
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment.message,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      DateUtil.formatThaiDate(comment.commentCreatedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
