import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/constants/project_status_enum.dart';
import 'package:srv_paperless/data/model/project_model.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/viewmodel/budget_year_view_model.dart';
import 'package:srv_paperless/viewmodel/project_view_model.dart';
import 'package:srv_paperless/viewmodel/user_view_model.dart';
import 'package:srv_paperless/widgets/alert_confirm_widget.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:srv_paperless/widgets/custom_text_field.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/project/project_detail_look_only.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

class ProjectCreateScreen extends ConsumerStatefulWidget {
  final String? draftId;

  const ProjectCreateScreen({super.key, this.draftId});

  @override
  ConsumerState<ProjectCreateScreen> createState() =>
      _ProjectCreateScreenState();
}

class _ProjectCreateScreenState extends ConsumerState<ProjectCreateScreen> {
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController projectChairmanController =
      TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController requestCreateDateController =
      TextEditingController();
  String? _fileName;
  DateTime? _dateTime;
  File? _selectedFile;
  bool _isLoading = false;
  Project? _project;

  Future<void> _loadDraft() async {
    if (widget.draftId == null) {
      _dateTime = DateTime.now();
      requestCreateDateController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(_dateTime!);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final draft = await ref.read(projectByIdProvider(widget.draftId!).future);

      if (draft != null) {
        projectNameController.text = draft.projectName ?? '';
        projectChairmanController.text = draft.chairman ?? '';
        budgetController.text = draft.budget.toString();
        _project = draft;

        if (draft.date != null) {
          _dateTime = draft.date;
          requestCreateDateController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(draft.date!);
        }

        if (draft.pdfPath != null && draft.pdfPath!.isNotEmpty) {
          _fileName = draft.pdfPath;
        }
      }
    } catch (e) {
      debugPrint("Error loading draft: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => Container(
            height: 300,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        child: const Text('ยกเลิก'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      CupertinoButton(
                        child: const Text('ตกลง'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _dateTime ?? DateTime.now(),
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        requestCreateDateController.text = DateFormat(
                          'dd/MM/yyyy',
                        ).format(newDateTime);
                        _dateTime = newDateTime;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        String? filePath = result.files.single.path;

        if (filePath != null) {
          setState(() {
            _fileName = result.files.single.name;
            _selectedFile = File(filePath);
          });
        }
      }
    } catch (e) {
      debugPrint("Error at _pickPDF: $e");
    }
  }

  Future<void> _handleSave({required bool isDraft}) async {
    if (!isDraft) {
      if (projectNameController.text.isEmpty ||
          projectChairmanController.text.isEmpty ||
          budgetController.text.isEmpty ||
          (_fileName == null && _selectedFile == null)) {
        _showSnackBar(
          context,
          'กรุณากรอกข้อมูลให้ครบทุกช่องและแนบไฟล์ PDF',
          Colors.red,
        );
        return;
      }
    }

    final authAsync = ref.read(authProvider);
    final user = authAsync.value?.currentUser;
    final thisBudgetYear = ref.read(budgetYearByThisYearProvider).value?.id;

    if (user == null) return;

    final projectData = Project(
      projectName: projectNameController.text,
      chairman: projectChairmanController.text,
      budget: double.tryParse(budgetController.text) ?? 0.0,
      date: _dateTime,
      fixLatest: DateTime.now(),
      id: widget.draftId ?? '',
      userId: user.id,
      pdfPath: _fileName ?? '',
      status: isDraft ? ProjectStatus.draft : ProjectStatus.pending,
      budgetYear: thisBudgetYear ?? '',
    );

    if (widget.draftId == null) {
      await ref
          .read(projectProvider.notifier)
          .saveProject(
            project: projectData,
            isDraft: isDraft,
            pdfFile: _selectedFile,
          );
    } else {
      await ref
          .read(projectProvider.notifier)
          .updateProject(
            id: widget.draftId!,
            project: projectData,
            pdfFile: _selectedFile,
          );
    }

    final state = ref.read(projectProvider);
    if (!state.hasError) {
      ref.invalidate(draftProjectsProvider(user.id));
      if (mounted) {
        Navigator.of(context).pop();
        _showSnackBar(
          context,
          isDraft ? 'บันทึกฉบับร่างสำเร็จ' : 'สร้างโครงการสำเร็จ',
          Colors.green,
        );
      }
    } else {
      if (mounted) {
        _showSnackBar(context, 'เกิดข้อผิดพลาด: ${state.error}', Colors.red);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadDraft());
  }

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final authState = ref.watch(authProvider);
    final user = authState.value?.currentUser;

    // เช็คข้อมูลโปรเจกต์และผู้ใช้
    final bool isCreatingNew = widget.draftId == null;
    final bool isProjectLoaded = _project != null;
    final bool isUserLoaded = user != null;

    // ตรวจสอบเงื่อนไขความเป็นเจ้าของ
    bool isOwner = isCreatingNew || (isProjectLoaded && isUserLoaded && _project!.userId == user.id);

    return MenuWidget(
      title: const HeaderLogoWithBackButton(),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: SafeArea(
                  child: Center(
                    child: Column(
                      children: [
                        if (isOwner) ...[
                          TitleSmall(
                            title: "โครงการของฉัน",
                            des:
                                widget.draftId != null
                                    ? "แก้ไขฉบับร่าง"
                                    : "ยื่นโครงการ",
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.08,
                            ),
                            child: Column(
                              children: [
                                CustomTextField(
                                  label: "ชื่อโครงการ",
                                  hint: "",
                                  controller: projectNameController,
                                ),
                                const SizedBox(height: 12),
                                CustomTextField(
                                  label: "ประธานโครงการ",
                                  hint: "",
                                  controller: projectChairmanController,
                                ),
                                const SizedBox(height: 12),
                                CustomTextField(
                                  label: "เสนอโครงการวันที่",
                                  hint: "เลือกวันที่",
                                  controller: requestCreateDateController,
                                  readOnly: true,
                                  onTap: () => _showDatePicker(context),
                                ),
                                const SizedBox(height: 12),
                                CustomTextField(
                                  label: "จำนวนเงิน(บาท)",
                                  hint: "0.00",
                                  controller: budgetController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "แนบเอกสารโครงการ (PDF)",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: _pickPDF,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 15,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.picture_as_pdf,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                _fileName ??
                                                    "คลิกเพื่อเลือกไฟล์ PDF",
                                                style: TextStyle(
                                                  color:
                                                      _fileName == null
                                                          ? Colors.grey
                                                          : Colors.black,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            if (_fileName != null)
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _fileName = null;
                                                    _selectedFile = null;
                                                  });
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                CustomButton(
                                  height: 55,
                                  text: const Text(
                                    "บันทึกฉบับร่าง",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  border: 15,
                                  color: const Color(0xff3A6BB5),
                                  onPressed:
                                      () => showDialog(
                                        context: context,
                                        builder:
                                            (_) => AlertConfirmWidget(
                                              title:
                                                  "คุณต้องการบันทึกฉบับร่างหรือไม่",
                                              onConfirm:
                                                  () =>
                                                      _handleSave(isDraft: true),
                                            ),
                                      ),
                                ),
                                const SizedBox(height: 20),
                                CustomButton(
                                  height: 55,
                                  text: const Text(
                                    "สร้างโครงการ",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  border: 15,
                                  color: const Color(0xff3A9AB5),
                                  onPressed:
                                      () => showDialog(
                                        context: context,
                                        builder:
                                            (_) => AlertConfirmWidget(
                                              title:
                                                  "คุณต้องการสร้างโครงการหรือไม่",
                                              onConfirm:
                                                  () =>
                                                      _handleSave(isDraft: false),
                                            ),
                                      ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ] else if (_project != null) ...[
                          Consumer(
                            builder: (context, ref, child) {
                              final ownerAsync = ref.watch(userByIdProvider(_project!.userId));
                              return ownerAsync.when(
                                data: (owner) => Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: TitleNormal(
                                    title: "ยื่นโครงการ",
                                    des: "ของ ${owner?.fullname ?? 'ไม่ระบุ'}",
                                  ),
                                ),
                                loading: () => const TitleSmall(title: "กำลังโหลด...", des: ""),
                                error: (_, __) => const TitleSmall(title: "ไม่สามารถโหลดชื่อเจ้าของได้", des: ""),
                              );
                            },
                          ),
                          ProjectDetailLookOnly(project: _project!)
                        ]
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String text,
    Color color,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
  }
}
