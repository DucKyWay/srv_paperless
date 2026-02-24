import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:srv_paperless/core/utils/date_util.dart';
import 'package:srv_paperless/data/model/project_model.dart';
import 'package:srv_paperless/viewmodel/project_view_model.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

class ProjectRequestScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectRequestScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectRequestScreen> createState() =>
      _ProjectRequestScreenState();
}

class _ProjectRequestScreenState extends ConsumerState<ProjectRequestScreen> {
  late Project project;

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
                          "ชื่อโครงการ: ${project.projectName}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                          "อนุมิติโครงการ : ${project.status}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "แก้ไขล่าสุด : ${DateUtil.formatThaiDate(project.fixLatest)}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
