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
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getStatusColor(project.status), // ใช้สีตามสถานะ
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getBorderColor(project.status), // ใช้สีขอบตามสถานะ
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                      radius: 45,
                      backgroundColor: Colors.blue[100],
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  final imageUrl = snapshot.data;

                  return Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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
                            "ชื่อโครงการ: ${project.projectName}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // เพิ่ม Badge แสดงสถานะ
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getBorderColor(project.status),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            project.status?.label ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ผู้ยื่นโครงการ : ${user?.fullname}",
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ยื่นเมื่อ : ${DateUtil.formatIntlDate(project.date)}",
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            routes,
                            arguments: project.id,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff76B947),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "รายละเอียด",
                          style: TextStyle(fontWeight: FontWeight.bold),
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
}

class CommentCardWidget extends ProjectCardWidget {
  final Comment comment;

  const CommentCardWidget({super.key, required this.comment});

  @override
  Widget buildLeading(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(comment.userId));

    return userAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (commentor) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.fromLTRB(10, 5, 20, 20),
          decoration: BoxDecoration(
            color: const Color(0xffFFDAD5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const SizedBox(height: 24),
                  FutureBuilder<String>(
                    future: getPrivateFileUrl(commentor?.image ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.blue[100],
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        );
                      }

                      final imageUrl = snapshot.data;

                      return Container(
                        width: 90, // radius * 2
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
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
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: RichText(
                        text: const TextSpan(
                          text: "หมายเหตุ",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                          children: [
                            TextSpan(
                              text: "*",
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ชื่อ: ${commentor?.fullname ?? 'ไม่ทราบชื่อ'}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(comment.message),
                    const SizedBox(height: 8),
                    Text(
                      DateUtil.formatThaiDate(comment.commentCreatedAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
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
