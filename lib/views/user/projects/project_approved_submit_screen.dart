import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:srv_paperless/core/constants/project_status_enum.dart';
import 'package:srv_paperless/data/model/project_location_model.dart';
import 'package:srv_paperless/viewmodel/projects/project_location_view_model.dart';
import 'package:srv_paperless/widgets/custom_text_field.dart';

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
import 'location_picker_screen.dart';

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
    // Debug API Key
    final apiKey = dotenv.env['GOOGLE_MAP_API_KEY'];
    debugPrint("[SRV DEBUG] Google Map API Key from .env: $apiKey");
    
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    final projectData =
        await ref.read(projectByIdProvider(widget.projectId).future);
    if (projectData == null) return;
    if (mounted) setState(() => project = projectData);
  }

  Future<void> _handleStartProject() async {
    if (project == null) return;
    final updatedProject = project!.copyWith(
      status: ProjectStatus.started,
      fixLatest: DateTime.now(),
    );
    await ref
        .read(projectProvider.notifier)
        .updateProject(id: project!.id, project: updatedProject);
    if (!ref.read(projectProvider).hasError && mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('เริ่มโครงการสำเร็จ'), backgroundColor: Colors.green));
    }
  }

  Future<void> _handleSaveProgress({
    required XFile? image,
    required String detail,
    required String note,
    LatLng? pickedLocation,
    String? existingId,
    String? existingImagePath,
  }) async {
    final repository = ref.read(projectLocationProvider.notifier);
    final geoPoint = pickedLocation != null 
        ? GeoPoint(pickedLocation.latitude, pickedLocation.longitude) 
        : null;

    if (existingId == null) {
      if (image == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("กรุณาเลือกรูปภาพ")));
        return;
      }
      final newLoc = ProjectLocation(
          id: '',
          requestId: project!.id,
          locationImagePath: '',
          locationImageDetail: detail,
          note: note,
          location: geoPoint);
      await repository.createLocationWithImage(
          projectLocation: newLoc, imageFile: image);
    } else {
      final updatedLoc = ProjectLocation(
          id: existingId,
          requestId: project!.id,
          locationImagePath: existingImagePath,
          locationImageDetail: detail,
          note: note,
          location: geoPoint);
      await repository.updateLocationWithImage(
          id: existingId, projectLocation: updatedLoc, imageFile: image);
    }

    if (mounted) Navigator.pop(context);
  }

  void _showProgressSheet({ProjectLocation? existingLoc}) async {
    final TextEditingController detailController =
        TextEditingController(text: existingLoc?.locationImageDetail);
    final TextEditingController noteController =
        TextEditingController(text: existingLoc?.note);
    XFile? selectedImage;
    String? currentImageUrl;
    LatLng? pickedLatLng;

    if (existingLoc?.location != null) {
      pickedLatLng = LatLng(existingLoc!.location!.latitude, existingLoc.location!.longitude);
    }

    if (existingLoc != null) {
      currentImageUrl = await getPrivateFileUrl(existingLoc.locationImagePath ?? '');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(existingLoc == null ? "เพิ่มความคืบหน้า" : "แก้ไขความคืบหน้า",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300)),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(File(selectedImage!.path),
                                fit: BoxFit.cover))
                        : (currentImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(currentImageUrl,
                                    fit: BoxFit.cover))
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Icon(Icons.add_a_photo_rounded,
                                        size: 50, color: Colors.grey[400]),
                                    const SizedBox(height: 10),
                                    const Text("แตะเพื่อเปลี่ยนรูปภาพ",
                                        style: TextStyle(color: Colors.grey))
                                  ])),
                  ),
                ),
                const SizedBox(height: 20),
                
                CustomButton(
                  height: 45,
                  text: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(pickedLatLng == null ? "เลือกสถานที่จากแผนที่" : "เปลี่ยนสถานที่", 
                        style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                  color: Colors.orange.shade700,
                  border: 15,
                  onPressed: () async {
                    final result = await Navigator.push<LocationResult>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationPickerScreen(
                          initialLocation: pickedLatLng ?? const LatLng(13.8476, 100.5696),
                        ),
                      ),
                    );
                    if (result != null) {
                      setModalState(() {
                        pickedLatLng = result.latLng;
                        if (detailController.text.isEmpty) {
                          detailController.text = result.address;
                        }
                      });
                    }
                  },
                ),
                
                if (pickedLatLng != null) ...[
                  const SizedBox(height: 8),
                  Text("พิกัดที่เลือก: ${pickedLatLng!.latitude.toStringAsFixed(4)}, ${pickedLatLng!.longitude.toStringAsFixed(4)}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],

                const SizedBox(height: 20),
                CustomTextField(
                    label: "คำอธิบายภาพ (ชื่อสถานที่)", controller: detailController),
                const SizedBox(height: 12),
                CustomTextField(label: "หมายเหตุ", controller: noteController),
                const SizedBox(height: 25),
                Row(
                  children: [
                    if (existingLoc != null)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: CustomButton(
                            height: 55,
                            text: const Text("ลบ", style: TextStyle(color: Colors.white)),
                            color: Colors.red,
                            border: 15,
                            onPressed: () async {
                              await ref.read(projectLocationProvider.notifier).deleteLocation(existingLoc.id!, existingLoc.requestId!);
                              if (mounted) Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    Expanded(
                      child: CustomButton(
                        height: 55,
                        text: const Text("บันทึก", style: TextStyle(color: Colors.white)),
                        color: const Color(0xff3A9AB5),
                        border: 15,
                        onPressed: () => _handleSaveProgress(
                          image: selectedImage,
                          detail: detailController.text,
                          note: noteController.text,
                          pickedLocation: pickedLatLng,
                          existingId: existingLoc?.id,
                          existingImagePath: existingLoc?.locationImagePath,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (project == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final width = context.screenWidth;

    return MenuWidget(
      title: const HeaderWithBackButton(),
      floatingActionButton: project?.status == ProjectStatus.started
          ? FloatingActionButton.extended(
              onPressed: () => _showProgressSheet(),
              backgroundColor: const Color(0xff3A9AB5),
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text("อัปเดตงาน",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _projectProgressList(context, ref),
                ] else ...[
                  const Text("หมายเหตุ/ความคิดเห็น",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    border: 15,
                    color: const Color(0xff3A9AB5),
                    onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AlertConfirmWidget(
                            title: "ยืนยันการเริ่มโครงการ?",
                            onConfirm: _handleStartProject)))),
        ],
      ),
    );
  }

  Widget _projectProgressList(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(projectLocationsProvider(widget.projectId));
    return progressAsync.when(
      data: (locations) => locations.isEmpty
          ? const Center(
              child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("ยังไม่มีข้อมูลความคืบหน้า",
                  style: TextStyle(color: Colors.grey)),
            ))
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final loc = locations[index];
                return GestureDetector(
                  onTap: () => _showProgressSheet(existingLoc: loc),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: getPrivateFileUrl(loc.locationImagePath ?? ''),
                          builder: (context, snapshot) => snapshot.hasData
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                  child: Image.network(snapshot.data!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover))
                              : const SizedBox(
                                  height: 200,
                                  child: Center(
                                      child: CircularProgressIndicator())),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "คำอธิบายภาพ : ${loc.locationImageDetail ?? ''}",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              if (loc.note != null && loc.note!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text("หมายเหตุ : ${loc.note}",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[700])),
                              ],
                              if (loc.location != null) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Text("แสดงตำแหน่งในโครงการ", 
                                      style: TextStyle(fontSize: 12, color: Colors.blue.shade700, decoration: TextDecoration.underline)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) =>
          const Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล")),
    );
  }

  Widget _projectComments(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentByProjectId(project!.id));
    return commentsAsync.when(
      data: (comments) => comments.isEmpty
          ? const SizedBox.shrink()
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) =>
                  CommentCardWidget(comment: comments[index])),
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
          ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('ถ่ายรูป'),
              onTap: () => Navigator.pop(context, ImageSource.camera)),
          ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('เลือกจากแกลเลอรี'),
              onTap: () => Navigator.pop(context, ImageSource.gallery)),
        ],
      ),
    );
  }
}
