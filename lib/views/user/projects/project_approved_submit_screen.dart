import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:srv_paperless/core/constants/project_status_enum.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:srv_paperless/data/minio.dart';
import 'package:srv_paperless/data/model/project_location_model.dart';
import 'package:srv_paperless/data/model/project_model.dart';
import 'package:srv_paperless/viewmodel/comment_view_model.dart';
import 'package:srv_paperless/viewmodel/project_view_model.dart';
import 'package:srv_paperless/viewmodel/projects/project_location_view_model.dart';
import 'package:srv_paperless/widgets/alert_confirm_widget.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:srv_paperless/widgets/custom_text_field.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/project/card_widget.dart';
import 'package:srv_paperless/widgets/project/project_info_card.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

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
  bool _isActionProcessing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadData);
  }

  Future<void> _loadData() async {
    final projectData =
        await ref.read(projectByIdProvider(widget.projectId).future);
    if (projectData == null) return;
    if (mounted) setState(() => project = projectData);
  }

  Future<void> _handleUpdateStatus(ProjectStatus newStatus, String message) async {
    if (project == null || _isActionProcessing) return;

    setState(() => _isActionProcessing = true);

    final updatedProject = project!.copyWith(
      status: newStatus,
      fixLatest: DateTime.now(),
    );

    await ref
        .read(projectProvider.notifier)
        .updateProject(id: project!.id, project: updatedProject);

    if (!mounted) return;
    setState(() => _isActionProcessing = false);

    if (!ref.read(projectProvider).hasError) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _handleStartProject() async {
    if (project == null || _isActionProcessing) return;

    setState(() => _isActionProcessing = true);

    final updatedProject = project!.copyWith(
      status: ProjectStatus.started,
      fixLatest: DateTime.now(),
    );

    await ref
        .read(projectProvider.notifier)
        .updateProject(id: project!.id, project: updatedProject);

    if (!mounted) return;
    setState(() => _isActionProcessing = false);

    if (!ref.read(projectProvider).hasError) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เริ่มโครงการสำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<bool> _handleSaveProgressList({
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

    try {
      if (existingId == null) {
        if (image == null) return false;
        final newLoc = ProjectLocation(
          id: '',
          requestId: project!.id,
          locationImagePath: '',
          locationImageDetail: detail,
          note: note,
          location: geoPoint,
        );
        await repository.createLocationWithImage(
          projectLocation: newLoc,
          imageFile: image,
        );
      } else {
        final updatedLoc = ProjectLocation(
          id: existingId,
          requestId: project!.id,
          locationImagePath: existingImagePath,
          locationImageDetail: detail,
          note: note,
          location: geoPoint,
        );
        await repository.updateLocationWithImage(
          id: existingId,
          projectLocation: updatedLoc,
          imageFile: image,
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error saving progress: $e');
      return false;
    }
  }

  void _showProgressSheet({ProjectLocation? existingLoc}) async {
    final detailController =
        TextEditingController(text: existingLoc?.locationImageDetail);
    final noteController =
        TextEditingController(text: existingLoc?.note);

    XFile? selectedImage;
    String? currentImageUrl;
    LatLng? pickedLatLng;

    if (existingLoc?.location != null) {
      pickedLatLng = LatLng(
        existingLoc!.location!.latitude,
        existingLoc.location!.longitude,
      );
    }

    if (existingLoc != null) {
      currentImageUrl =
          await getPrivateFileUrl(existingLoc.locationImagePath ?? '');
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          bool isSaving = false;

          void _showErrorDialog(String message) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 10),
                    Text('แจ้งเตือน'),
                  ],
                ),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('เข้าใจแล้ว'),
                  ),
                ],
              ),
            );
          }

          Future<void> onSave() async {
            if (existingLoc == null && 
                selectedImage == null && 
                detailController.text.trim().isEmpty && 
                pickedLatLng == null) {
              _showErrorDialog('กรุณากรอกข้อมูลความคืบหน้าอย่างน้อยหนึ่งอย่าง เช่น เลือกรูปภาพหรือระบุรายละเอียด');
              return;
            }

            if (existingLoc == null && selectedImage == null) {
              _showErrorDialog('กรุณาเลือกรูปภาพความคืบหน้า');
              return;
            }

            if (detailController.text.trim().isEmpty) {
              _showErrorDialog('กรุณากรอกคำอธิบายภาพหรือสถานที่');
              return;
            }

            setModalState(() => isSaving = true);

            final success = await _handleSaveProgressList(
              image: selectedImage,
              detail: detailController.text,
              note: noteController.text,
              pickedLocation: pickedLatLng,
              existingId: existingLoc?.id,
              existingImagePath: existingLoc?.locationImagePath,
            );

            if (!context.mounted) return;

            if (success) {
              Navigator.pop(context);
            } else {
              setModalState(() => isSaving = false);
              _showErrorDialog('บันทึกไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    existingLoc == null ? 'เพิ่มความคืบหน้า' : 'แก้ไขความคืบหน้า',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: isSaving ? null : () async {
                      final source = await showModalBottomSheet<ImageSource>(
                        context: context,
                        builder: (_) => const ImageSourceSheetContent(),
                      );
                      if (source == null) return;
                      final image = await ImagePicker().pickImage(source: source);
                      if (image != null) setModalState(() => selectedImage = image);
                    },
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _buildImagePreview(
                        selectedImage: selectedImage,
                        currentImageUrl: currentImageUrl,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    height: 45,
                    color: Colors.orange.shade700,
                    border: 15,
                    text: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          pickedLatLng == null ? 'เลือกสถานที่' : 'เปลี่ยนสถานที่',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    onPressed: isSaving ? null : () async {
                      final result = await Navigator.push<LocationResult>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LocationPickerScreen(
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
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'คำอธิบายภาพ',
                    controller: detailController,
                    hint: 'ระบุสถานที่หรือกิจกรรม',
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'หมายเหตุ (ถ้ามี)',
                    controller: noteController,
                    hint: 'ข้อมูลเพิ่มเติม',
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      if (existingLoc != null)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: CustomButton(
                              height: 55,
                              text: const Text('ลบ', style: TextStyle(color: Colors.white)),
                              color: Colors.red,
                              border: 15,
                              onPressed: isSaving ? null : () async {
                                setModalState(() => isSaving = true);
                                await ref.read(projectLocationProvider.notifier).deleteLocation(existingLoc.id!, existingLoc.requestId!);
                                if (context.mounted) Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      Expanded(
                        child: CustomButton(
                          height: 55,
                          color: const Color(0xff3A9AB5),
                          border: 15,
                          text: isSaving
                              ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('บันทึก', style: TextStyle(color: Colors.white)),
                          onPressed: onSave,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePreview({
    required XFile? selectedImage,
    required String? currentImageUrl,
  }) {
    if (selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(File(selectedImage.path), fit: BoxFit.cover),
      );
    }
    if (currentImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(currentImageUrl, fit: BoxFit.cover),
      );
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_rounded, size: 50, color: Colors.grey),
        SizedBox(height: 10),
        Text('แตะเพื่อแนบรูปภาพ', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (project == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final width = context.screenWidth;
    final isStarted = project?.status == ProjectStatus.started;
    final isApproved = project?.status == ProjectStatus.approve;

    return MenuWidget(
      title: const HeaderWithBackButton(),
      floatingActionButton: isStarted
          ? FloatingActionButton.extended(
              onPressed: () => _showProgressSheet(),
              backgroundColor: const Color(0xff3A9AB5),
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text('อัปเดตงาน', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          const TitleNormal(title: 'รายละเอียดโครงการ'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ProjectInfoCard(project: project!),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStarted ? 'ความคืบหน้าโครงการ' : 'หมายเหตุ/ความคิดเห็น',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                isStarted
                    ? _ProjectProgressList(
                        projectId: widget.projectId,
                        onTapItem: (loc) => _showProgressSheet(existingLoc: loc),
                        onFinish: () => showDialog(
                          context: context,
                          builder: (_) => AlertConfirmWidget(
                            title: 'คุณต้องการสิ้นสุดโครงการหรือไม่?',
                            onConfirm: () => _handleUpdateStatus(ProjectStatus.finished, 'สิ้นสุดโครงการสำเร็จ'),
                          ),
                        ),
                      )
                    : _ProjectComments(projectId: project!.id),
              ],
            ),
          ),
          if (isApproved)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomButton(
                height: 55,
                text: const Text('เริ่มโครงการ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                border: 15,
                color: const Color(0xff3A9AB5),
                onPressed: _isActionProcessing
                    ? null
                    : () => showDialog(
                          context: context,
                          builder: (_) => AlertConfirmWidget(
                            title: 'ยืนยันการเริ่มโครงการ?',
                            onConfirm: _handleStartProject,
                          ),
                        ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProjectProgressList extends ConsumerWidget {
  final String projectId;
  final Function(ProjectLocation) onTapItem;
  final VoidCallback onFinish;

  const _ProjectProgressList({
    required this.projectId,
    required this.onTapItem,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(projectLocationsProvider(projectId));

    return progressAsync.when(
      data: (locations) {
        if (locations.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('ยังไม่มีข้อมูลความคืบหน้า', style: TextStyle(color: Colors.grey)),
            ),
          );
        }
        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final loc = locations[index];
                return GestureDetector(
                  onTap: () => onTapItem(loc),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProgressImage(imagePath: loc.locationImagePath),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('คำอธิบายภาพ : ${loc.locationImageDetail ?? ''}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              if (loc.note != null && loc.note!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('หมายเหตุ : ${loc.note}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                              ],
                              if (loc.location != null) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Text('แสดงตำแหน่งในโครงการ', style: TextStyle(fontSize: 12, color: Colors.blue.shade700, decoration: TextDecoration.underline)),
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
            const SizedBox(height: 10),
            CustomButton(
              text: const Text("จบโครงการ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
              border: 15, 
              color: Theme.of(context).colorScheme.primaryContainer,
              onPressed: onFinish,
            )
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล')),
    );
  }
}

class _ProgressImage extends StatelessWidget {
  final String? imagePath;
  const _ProgressImage({this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) return const SizedBox(height: 200, child: Center(child: Icon(Icons.image_not_supported, size: 50)));
    return FutureBuilder<String>(
      future: getPrivateFileUrl(imagePath!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(snapshot.data!, height: 200, width: double.infinity, fit: BoxFit.cover),
          );
        }
        return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _ProjectComments extends ConsumerWidget {
  final String projectId;
  const _ProjectComments({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentsByProjectId(projectId));
    return commentsAsync.when(
      data: (comments) {
        if (comments.isEmpty) return const SizedBox.shrink();
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) => CommentCardWidget(comment: comments[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text('โหลดหมายเหตุไม่สำเร็จ')),
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
