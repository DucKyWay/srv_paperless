import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:srv_paperless/core/constants/project_status_enum.dart';
import 'package:srv_paperless/data/model/project_location_model.dart';
import 'package:srv_paperless/viewmodel/projects/project_location_view_model.dart';

import '../../../core/utils/screen_size.dart';
import '../../../data/minio.dart';
import '../../../data/model/project_model.dart';
import '../../../viewmodel/comment_view_model.dart';
import '../../../viewmodel/project_view_model.dart';
import '../../../widgets/alert_confirm_widget.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/menu_header_widget.dart';
import '../../../widgets/menu_widget.dart';
import '../../../widgets/project/card_widget.dart';
import '../../../widgets/project/project_info_card.dart';
import '../../../widgets/title_widget.dart';

class ProjectApprovedSubmitScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectApprovedSubmitScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectApprovedSubmitScreen> createState() =>
      _ProjectApprovedSubmitScreenState();
}

class _ProjectApprovedSubmitScreenState
    extends ConsumerState<ProjectApprovedSubmitScreen> {
  Project? project;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    final projectData = await ref.read(projectByIdProvider(widget.projectId).future);
    if (projectData == null) return;
    if (mounted) setState(() => project = projectData);
  }

  Future<void> _handleStartProject() async {
    if (project == null) return;
    final updatedProject = project!.copyWith(
      status: ProjectStatus.started,
      fixLatest: DateTime.now(),
    );
    await ref.read(projectProvider.notifier).updateProject(id: project!.id, project: updatedProject);
    if (!ref.read(projectProvider).hasError && mounted) {
      Navigator.of(context).pop(); Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เริ่มโครงการสำเร็จ'), backgroundColor: Colors.green));
    }
  }

  void _showAddProgressSheet() {
    final TextEditingController detailController = TextEditingController();
    XFile? selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("เพิ่มความคืบหน้าโครงการ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final source = await showModalBottomSheet<ImageSource>(
                    context: context,
                    builder: (context) => const ImageSourceSheetContent(),
                  );
                  if (source != null) {
                    final image = await ImagePicker().pickImage(source: source);
                    if (image != null) setModalState(() => selectedImage = image);
                  }
                },
                child: Container(
                  height: 180, width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
                  child: selectedImage == null
                      ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_rounded, size: 50, color: Colors.grey[400]), const SizedBox(height: 10), const Text("แตะเพื่อแนบรูปภาพ", style: TextStyle(color: Colors.grey))])
                      : ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(File(selectedImage!.path), fit: BoxFit.cover)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: detailController,
                decoration: InputDecoration(labelText: "รายละเอียด/คำอธิบาย", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), filled: true, fillColor: Colors.grey[50]),
                maxLines: 3,
              ),
              const SizedBox(height: 25),
              CustomButton(
                height: 55, text: const Text("บันทึกข้อมูล", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                border: 15,
                color: const Color(0xff3A9AB5),
                onPressed: () async {
                  if (selectedImage == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("กรุณาเลือกรูปภาพ"))); return; }
                  final newLoc = ProjectLocation(id: '', requestId: project!.id, locationImagePath: '', locationImageDetail: detailController.text, location: null);
                  await ref.read(projectLocationProvider.notifier).createLocationWithImage(projectLocation: newLoc, imageFile: selectedImage);
                  if (mounted) Navigator.pop(context);
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (project == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final width = context.screenWidth;

    return MenuWidget(
      title: const HeaderWithBackButton(),
      floatingActionButton: project?.status == ProjectStatus.started
          ? FloatingActionButton.extended(
              onPressed: _showAddProgressSheet,
              backgroundColor: const Color(0xff3A9AB5),
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text("อัปเดตงาน", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100), // เพิ่ม Padding ด้านล่างเผื่อสำหรับปุ่มหรือ FAB
        children: [
          const TitleNormal(title: "รายละเอียดโครงการ"),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ProjectInfoCard(project: project!),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (project?.status == ProjectStatus.started) ...[
                  const Text("ความคืบหน้าโครงการ", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _projectProgressList(context, ref),
                ] else ...[
                  const Text("หมายเหตุ/ความคิดเห็น", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _projectComments(context, ref),
                ],
              ],
            ),
          ),
          if (project?.status == ProjectStatus.approve)
            Padding(
              padding: const EdgeInsets.all(20.0), 
              child: CustomButton(
                height: 55, 
                text: const Text("เริ่มโครงการ", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), 
                border: 15, 
                color: const Color(0xff3A9AB5), 
                onPressed: () => showDialog(
                  context: context, 
                  builder: (_) => AlertConfirmWidget(
                    title: "ยืนยันการเริ่มโครงการ?", 
                    onConfirm: _handleStartProject
                  )
                )
              )
            ),
        ],
      ),
    );
  }

  Widget _projectProgressList(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(projectLocationsProvider(widget.projectId));
    return progressAsync.when(
      data: (locations) => locations.isEmpty 
          ? const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("ยังไม่มีข้อมูลความคืบหน้า", style: TextStyle(color: Colors.grey)),
            )) 
          : ListView.builder(
              shrinkWrap: true, // สำคัญ: เพื่อให้เลื่อนไปกับหน้าจอหลักได้
              physics: const NeverScrollableScrollPhysics(), // ปิดการเลื่อนของลิสต์ภายใน
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final loc = locations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 20), elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    FutureBuilder<String>(
                      future: getPrivateFileUrl(loc.locationImagePath ?? ''),
                      builder: (context, snapshot) => snapshot.hasData 
                          ? ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.network(snapshot.data!, height: 200, width: double.infinity, fit: BoxFit.cover))
                          : const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                    ),
                    Padding(padding: const EdgeInsets.all(15), child: Text(loc.locationImageDetail ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                  ]),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล")),
    );
  }

  Widget _projectComments(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentByProjectId(project!.id));
    return commentsAsync.when(
      data: (comments) => comments.isEmpty 
          ? const SizedBox.shrink() 
          : ListView.builder(
              shrinkWrap: true, // สำคัญ
              physics: const NeverScrollableScrollPhysics(), // ปิดการเลื่อนของลิสต์ภายใน
              itemCount: comments.length, 
              itemBuilder: (context, index) => CommentCardWidget(comment: comments[index])
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text("โหลดหมายเหตุไม่สำเร็จ")),
    );
  }
}

class ImageSourceSheetContent extends StatelessWidget {
  const ImageSourceSheetContent({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(leading: const Icon(Icons.camera_alt), title: const Text('ถ่ายรูป'), onTap: () => Navigator.pop(context, ImageSource.camera)),
          ListTile(leading: const Icon(Icons.photo_library), title: const Text('เลือกจากแกลเลอรี'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
        ],
      ),
    );
  }
}
