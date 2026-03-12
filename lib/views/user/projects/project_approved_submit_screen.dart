import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:srv_paperless/core/constants/project_status_enum.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:srv_paperless/core/utils/snackbar_util.dart';
import 'package:srv_paperless/data/minio.dart';
import 'package:srv_paperless/data/model/project_location_model.dart';
import 'package:srv_paperless/data/model/project_model.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
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

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _kPrimaryColor = Color(0xff3A9AB5);
const _kDefaultLatLng = LatLng(13.8476, 100.5696);

// ---------------------------------------------------------------------------
// Typedefs
// ---------------------------------------------------------------------------

typedef SaveProgressCallback =
    Future<bool> Function({
      required XFile? image,
      required String detail,
      required String note,
      LatLng? location,
      String? existingId,
      String? existingImagePath,
    });

typedef DeleteLocationCallback = Future<void> Function(ProjectLocation loc);

// ---------------------------------------------------------------------------
// Main Screen
// ---------------------------------------------------------------------------

class ProjectApprovedSubmitScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectApprovedSubmitScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectApprovedSubmitScreen> createState() =>
      _ProjectApprovedSubmitScreenState();
}

class _ProjectApprovedSubmitScreenState
    extends ConsumerState<ProjectApprovedSubmitScreen> {
  Project? _project;
  bool _isOwner = false;
  bool _isActionProcessing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadProject);
  }

  Future<void> _loadProject() async {
    final data = await ref.read(projectByIdProvider(widget.projectId).future);
    if (data == null) return;

    final currentUser = ref.read(authProvider).value?.currentUser;

    if (mounted) {
      setState(() {
        _project = data;
        if (currentUser != null) {
          _isOwner = data.userId == currentUser.id;
        }
      });
    }
  }

  Future<void> _updateStatus(
    ProjectStatus newStatus,
    String successMessage,
  ) async {
    if (_project == null || _isActionProcessing) return;

    setState(() => _isActionProcessing = true);

    final updated = _project!.copyWith(
      status: newStatus,
      fixLatest: DateTime.now(),
    );

    await ref
        .read(projectProvider.notifier)
        .updateProject(id: _project!.id, project: updated);

    if (!mounted) return;
    setState(() => _isActionProcessing = false);

    if (!ref.read(projectProvider).hasError) {
      Navigator.of(context).pop();
      SnackBarWidget.success(context, successMessage);
    }
  }

  Future<void> _startProject() =>
      _updateStatus(ProjectStatus.started, 'เริ่มโครงการสำเร็จ');

  Future<void> _finishProject() =>
      _updateStatus(ProjectStatus.finished, 'สิ้นสุดโครงการสำเร็จ');

  Future<bool> _saveProgress({
    required XFile? image,
    required String detail,
    required String note,
    LatLng? location,
    String? existingId,
    String? existingImagePath,
  }) async {
    final repo = ref.read(projectLocationProvider.notifier);
    final geoPoint =
        location != null
            ? GeoPoint(location.latitude, location.longitude)
            : null;

    try {
      if (existingId == null) {
        if (image == null) return false;
        await repo.createLocationWithImage(
          projectLocation: ProjectLocation(
            id: '',
            requestId: _project!.id,
            locationImagePath: '',
            locationImageDetail: detail,
            note: note,
            location: geoPoint,
          ),
          imageFile: image,
        );
      } else {
        await repo.updateLocationWithImage(
          id: existingId,
          projectLocation: ProjectLocation(
            id: existingId,
            requestId: _project!.id,
            locationImagePath: existingImagePath,
            locationImageDetail: detail,
            note: note,
            location: geoPoint,
          ),
          imageFile: image,
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error saving progress: $e');
      return false;
    }
  }

  void _openProgressSheet({ProjectLocation? existing}) {
    if (!_isOwner) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder:
          (_) => _ProgressSheetContent(
            existing: existing,
            onSave: _saveProgress,
            onDelete:
                existing == null
                    ? null
                    : (loc) => ref
                        .read(projectLocationProvider.notifier)
                        .deleteLocation(loc.id!, loc.requestId!),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;

    if (_project == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isStarted = _project!.status == ProjectStatus.started;
    final isApproved = _project!.status == ProjectStatus.approve;

    return MenuWidget(
      title: const HeaderWithBackButton(),
      floatingActionButton: (isStarted && _isOwner) ? _buildFAB() : null,
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 16),
        children: [
          const TitleNormal(title: 'รายละเอียดโครงการ'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: width * 0.08),
            child: ProjectInfoCard(project: _project!),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStarted ? 'ความคืบหน้าโครงการ' : 'หมายเหตุ/ความคิดเห็น',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (isStarted)
                  _ProjectProgressList(
                    projectId: widget.projectId,
                    isOwner: _isOwner,
                    onTapItem:
                        _isOwner
                            ? (loc) => _openProgressSheet(existing: loc)
                            : (loc) {},
                    onFinish: () {
                      showDialog(
                        context: context,
                        builder:
                            (ctx) => AlertConfirmWidget(
                              title: 'คุณต้องการสิ้นสุดโครงการหรือไม่?',
                              onConfirm: () {
                                Navigator.pop(ctx);
                                _finishProject();
                              },
                            ),
                      );
                    },
                  )
                else
                  _ProjectComments(projectId: _project!.id),
              ],
            ),
          ),
          if (isApproved && _isOwner)
            Padding(
              padding: const EdgeInsets.all(20),
              child: CustomButton(
                height: 55,
                color: _kPrimaryColor,
                border: 15,
                onPressed: () {
                  if (!_isActionProcessing) {
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertConfirmWidget(
                            title: 'ยืนยันการเริ่มโครงการ',
                            onConfirm: () {
                              Navigator.pop(ctx);
                              _startProject();
                            },
                          ),
                    );
                  }
                },
                text: const Text(
                  'เริ่มโครงการ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFAB() => FloatingActionButton.extended(
    onPressed: () => _openProgressSheet(),
    backgroundColor: _kPrimaryColor,
    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
    label: const Text(
      'อัปเดตงาน',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}

// ---------------------------------------------------------------------------
// _ProgressSheetContent
// ---------------------------------------------------------------------------

class _ProgressSheetContent extends StatefulWidget {
  const _ProgressSheetContent({
    super.key,
    this.existing,
    required this.onSave,
    this.onDelete,
  });

  final ProjectLocation? existing;
  final SaveProgressCallback onSave;
  final DeleteLocationCallback? onDelete;

  @override
  State<_ProgressSheetContent> createState() => _ProgressSheetContentState();
}

class _ProgressSheetContentState extends State<_ProgressSheetContent> {
  bool _isSaving = false;
  XFile? _selectedImage;
  LatLng? _pickedLatLng;
  String? _currentImageUrl;

  late final TextEditingController _detailController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _detailController = TextEditingController(
      text: widget.existing?.locationImageDetail,
    );
    _noteController = TextEditingController(text: widget.existing?.note);

    if (widget.existing?.location != null) {
      _pickedLatLng = LatLng(
        widget.existing!.location!.latitude,
        widget.existing!.location!.longitude,
      );
    }

    _loadExistingImage();
  }

  @override
  void dispose() {
    _detailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingImage() async {
    final path = widget.existing?.locationImagePath;
    if (path == null || path.isEmpty) return;
    final url = await getPrivateFileUrl(path);
    if (mounted) setState(() => _currentImageUrl = url);
  }

  Future<void> _handleSave() async {
    if (widget.existing == null && _selectedImage == null) {
      _showError('กรุณาเลือกรูปภาพความคืบหน้า');
      return;
    }
    if (_detailController.text.trim().isEmpty) {
      _showError('กรุณากรอกคำอธิบายภาพหรือสถานที่');
      return;
    }

    setState(() => _isSaving = true);

    final success = await widget.onSave(
      image: _selectedImage,
      detail: _detailController.text,
      note: _noteController.text,
      location: _pickedLatLng,
      existingId: widget.existing?.id,
      existingImagePath: widget.existing?.locationImagePath,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      setState(() => _isSaving = false);
      _showError('บันทึกไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
    }
  }

  Future<void> _handleDelete() async {
    if (widget.onDelete == null) return;
    setState(() => _isSaving = true);
    await widget.onDelete!(widget.existing!);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => const ImageSourceSheetContent(),
    );
    if (source == null) return;
    final image = await ImagePicker().pickImage(source: source);
    if (image != null && mounted) setState(() => _selectedImage = image);
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(
        builder:
            (_) => LocationPickerScreen(
              initialLocation: _pickedLatLng ?? _kDefaultLatLng,
            ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _pickedLatLng = result.latLng;
        if (_detailController.text.isEmpty) {
          _detailController.text = result.address;
        }
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

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
              isEditing ? 'แก้ไขความคืบหน้า' : 'เพิ่มความคืบหน้า',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _isSaving ? null : _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _ImagePreview(
                  selectedImage: _selectedImage,
                  currentImageUrl: _currentImageUrl,
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              height: 45,
              color: Colors.orange.shade700,
              border: 15,
              onPressed: _isSaving ? null : _pickLocation,
              text: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _pickedLatLng == null ? 'เลือกสถานที่' : 'เปลี่ยนสถานที่',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'คำอธิบายภาพ',
              controller: _detailController,
              hint: 'ระบุสถานที่หรือกิจกรรม',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'หมายเหตุ (ถ้ามี)',
              controller: _noteController,
              hint: 'ข้อมูลเพิ่มเติม',
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                if (isEditing) ...[
                  Expanded(
                    child: CustomButton(
                      height: 55,
                      color: Colors.red,
                      border: 15,
                      onPressed: _isSaving ? null : _handleDelete,
                      text: const Text(
                        'ลบ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: CustomButton(
                    height: 55,
                    color: _kPrimaryColor,
                    border: 15,
                    onPressed: _isSaving ? null : _handleSave,
                    text:
                        _isSaving
                            ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'บันทึก',
                              style: TextStyle(color: Colors.white),
                            ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-Widgets
// ---------------------------------------------------------------------------

class _ProjectProgressList extends ConsumerWidget {
  const _ProjectProgressList({
    required this.projectId,
    required this.isOwner,
    required this.onTapItem,
    required this.onFinish,
  });
  final String projectId;
  final bool isOwner;
  final ValueChanged<ProjectLocation> onTapItem;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(projectLocationsProvider(projectId));
    return progressAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (_, __) => const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล')),
      data: (locations) {
        if (locations.isEmpty)
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'ยังไม่มีข้อมูลความคืบหน้า',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: locations.length,
              itemBuilder:
                  (context, index) => _ProgressCard(
                    location: locations[index],
                    onTap: () => onTapItem(locations[index]),
                  ),
            ),
            if (isOwner) ...[
              const SizedBox(height: 10),
              CustomButton(
                border: 15,
                color: Theme.of(context).colorScheme.primaryContainer,
                onPressed: onFinish,
                text: const Text(
                  'จบโครงการ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.location, required this.onTap});
  final ProjectLocation location;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProgressImage(imagePath: location.locationImagePath),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'คำอธิบายภาพ : ${location.locationImageDetail ?? ''}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
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
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'แสดงตำแหน่งในโครงการ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
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
  }
}

class _ProgressImage extends StatefulWidget {
  final String? imagePath;

  const _ProgressImage({this.imagePath});

  @override
  State<_ProgressImage> createState() => _ProgressImageState();
}

class _ProgressImageState extends State<_ProgressImage> {
  late Future<String> _futureUrl;

  @override
  void initState() {
    super.initState();
    _futureUrl = _loadImage();
  }

  Future<String> _loadImage() async {
    if (widget.imagePath == null || widget.imagePath!.isEmpty) {
      throw Exception("no image path");
    }
    return await getPrivateFileUrl(widget.imagePath!);
  }

  void _retry() {
    setState(() {
      _futureUrl = _loadImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _futureUrl,
      builder: (context, snapshot) {
        /// loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        /// success
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
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

        /// error
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.broken_image_outlined,
                  size: 45,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                const Text(
                  "โหลดภาพไม่สำเร็จ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text("ลองใหม่"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({this.selectedImage, this.currentImageUrl});
  final XFile? selectedImage;
  final String? currentImageUrl;
  @override
  Widget build(BuildContext context) {
    if (selectedImage != null)
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(File(selectedImage!.path), fit: BoxFit.cover),
      );
    if (currentImageUrl != null)
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(currentImageUrl!, fit: BoxFit.cover),
      );
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_rounded, size: 50, color: Colors.grey),
        SizedBox(height: 10),
        Text('แตะเพื่อแนบรูปภาพ', style: TextStyle(color: Colors.grey)),
      ],
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('โหลดหมายเหตุไม่สำเร็จ')),
      data: (comments) {
        if (comments.isEmpty) return const SizedBox.shrink();
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder:
              (_, index) => CommentCardWidget(comment: comments[index]),
        );
      },
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
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('เลือกจากแกลเลอรี'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}
