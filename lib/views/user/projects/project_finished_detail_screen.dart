import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:srv_paperless/data/minio.dart';
import 'package:srv_paperless/data/model/project_location_model.dart';
import 'package:srv_paperless/data/model/project_model.dart';
import 'package:srv_paperless/viewmodel/comment_view_model.dart';
import 'package:srv_paperless/viewmodel/project_view_model.dart';
import 'package:srv_paperless/viewmodel/projects/project_location_view_model.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/project/card_widget.dart';
import 'package:srv_paperless/widgets/project/project_info_card.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

class ProjectFinishedDetailScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectFinishedDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectFinishedDetailScreen> createState() => _ProjectFinishedDetailScreenState();
}

class _ProjectFinishedDetailScreenState extends ConsumerState<ProjectFinishedDetailScreen> {
  Project? _project;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadProject);
  }

  Future<void> _loadProject() async {
    final data = await ref.read(projectByIdProvider(widget.projectId).future);
    if (data != null && mounted) {
      setState(() => _project = data);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_project == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final width = context.screenWidth;

    return MenuWidget(
      title: const HeaderWithBackButton(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          const TitleNormal(title: 'สรุปผลการดำเนินโครงการ'),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ProjectInfoCard(project: _project!),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'บันทึกความคืบหน้าโครงการ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildProgressList(),
                const SizedBox(height: 24),
                const Text(
                  'หมายเหตุ/ความคิดเห็น',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildCommentsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressList() {
    final progressAsync = ref.watch(projectLocationsProvider(widget.projectId));

    return progressAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('ไม่สามารถโหลดข้อมูลความคืบหน้าได้')),
      data: (locations) {
        if (locations.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('ไม่มีบันทึกความคืบหน้า', style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: locations.length,
          itemBuilder: (context, index) => _ProgressCardReadOnly(location: locations[index]),
        );
      },
    );
  }

  Widget _buildCommentsList() {
    final commentsAsync = ref.watch(commentsByProjectId(_project!.id));
    return commentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('ไม่สามารถโหลดหมายเหตุได้')),
      data: (comments) {
        if (comments.isEmpty) return const Text('ไม่มีหมายเหตุเพิ่มเติม', style: TextStyle(color: Colors.grey, fontSize: 14));
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (_, index) => CommentCardWidget(comment: comments[index]),
        );
      },
    );
  }
}

class _ProgressCardReadOnly extends StatelessWidget {
  final ProjectLocation location;
  const _ProgressCardReadOnly({required this.location});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProgressImagePreview(imagePath: location.locationImagePath),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'คำอธิบาย : ${location.locationImageDetail ?? ""}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                if (location.note?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    'หมายเหตุ : ${location.note}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
                if (location.location != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        'ระบุตำแหน่งในระบบเรียบร้อย',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressImagePreview extends StatelessWidget {
  final String? imagePath;
  const _ProgressImagePreview({this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
      );
    }

    return FutureBuilder<String>(
      future: getPrivateFileUrl(imagePath!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              snapshot.data!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        }
        return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
