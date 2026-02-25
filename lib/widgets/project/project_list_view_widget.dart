import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/project_model.dart';
import 'package:srv_paperless/widgets/project/card_widget.dart';

class ProjectListViewWidget extends StatelessWidget {
  final AsyncValue<List<Project>> projectsAsync;
  final String emptyMessage;
  final String routePath;
  final Future<void> Function()? onRefresh; // เพิ่มตัวแปร callback สำหรับการรีเฟรช

  const ProjectListViewWidget({
    super.key,
    required this.projectsAsync,
    this.emptyMessage = "ไม่พบรายการ",
    required this.routePath,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return projectsAsync.when(
      data: (projects) {
        Widget child;
        if (projects.isEmpty) {
          child = SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.folder_open_rounded,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    emptyMessage,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "ดึงหน้าจอลงเพื่อโหลดข้อมูลใหม่",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          child = ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            itemCount: projects.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ProjectCardDetail(
                project: projects[index],
                routes: routePath,
              ),
            ),
          );
        }

        if (onRefresh != null) {
          return RefreshIndicator(
            onRefresh: onRefresh!,
            child: child,
          );
        }
        return child;
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) {
        final errorChild = SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text("เกิดข้อผิดพลาด: $err"),
                const SizedBox(height: 8),
                const Text("ดึงหน้าจอลงเพื่อลองใหม่"),
              ],
            ),
          ),
        );
        
        if (onRefresh != null) {
          return RefreshIndicator(onRefresh: onRefresh!, child: errorChild);
        }
        return errorChild;
      },
    );
  }
}
