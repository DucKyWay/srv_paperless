import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/project_model.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/viewmodel/project_view_model.dart';
import 'package:srv_paperless/widgets/alert_confirm_widget.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:srv_paperless/widgets/custom_text_field.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  final String? draftId;

  const CreateRequestScreen({super.key, this.draftId});

  @override
  ConsumerState<CreateRequestScreen> createState() =>
      _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController projectChairmanController =
      TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController requestCreateDateController =
      TextEditingController();
  String? _fileName;
  DateTime? _dateTime;
  File? _selectedFile;

  Future<void> _loadDraft() async {
    if (widget.draftId == null) return;

    final draft = await ref.read(projectByIdProvider(widget.draftId!).future);

    if (draft == null) return;

    projectNameController.text = draft.projectName ?? '';
    projectChairmanController.text = draft.chairman ?? '';
    budgetController.text = draft.budget.toString();

    if (draft.date != null) {
      _dateTime = draft.date;
      requestCreateDateController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(draft.date!);
    }

    if (draft.pdfPath != null && draft.pdfPath!.isNotEmpty) {
      _fileName = draft.pdfPath;
    }

    setState(() {});
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
                    initialDateTime: DateTime.now(),
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
        } else {
          debugPrint("File path is null. Trying to select from local storage?");
        }
      } else {
        debugPrint("User canceled the picker");
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
          _selectedFile == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณากรอกข้อมูลให้ครบทุกช่องและแนบไฟล์ PDF'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final authState = ref.read(authProvider);
    final user = authState.currentUser;

    if (user == null) return;
    final projectData = Project(
      projectName: projectNameController.text,
      chairman: projectChairmanController.text,
      budget: double.tryParse(budgetController.text) ?? 0.0,
      date: _dateTime,
      fixLatest: DateTime.now(),
      id: '',
      userId: user.id,
      pdfPath: _fileName ?? '',
    );

    await ref
        .read(projectProvider.notifier)
        .saveProject(
          project: projectData,
          isDraft: isDraft,
          pdfFile: _selectedFile,
        );

    final state = ref.read(projectProvider);
    if (!state.hasError) {
      ref.invalidate(draftProjectsProvider(user.id));
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDraft ? 'บันทึกฉบับร่างสำเร็จ' : 'สร้างโครงการสำเร็จ',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${state.error}')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _loadDraft();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;

    requestCreateDateController.text = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.now());
    return MenuWidget(
      title: HeaderLogoWithBackButton(),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                TitleSmall(
                  title:
                      widget.draftId != null ? "แก้ไขฉบับร่าง" : "ยื่นโครงการ",
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                  child: Column(
                    children: [
                      CustomTextField(
                        label: "ชื่อโครงการ",
                        hint: "",
                        controller: projectNameController,
                      ),
                      SizedBox(height: 12),
                      CustomTextField(
                        label: "ประธานโครงการ",
                        hint: "",
                        controller: projectChairmanController,
                      ),
                      SizedBox(height: 12),

                      // ส่วนของวันที่
                      CustomTextField(
                        label: "เสนอโครงการวันที่",
                        hint: "เลือกวันที่",
                        controller: requestCreateDateController,
                        readOnly: true,
                        onTap: () => _showDatePicker(context),
                      ),

                      SizedBox(height: 12),
                      CustomTextField(
                        label: "จำนวนเงิน(บาท)",
                        hint: "0.00",
                        controller: budgetController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      SizedBox(height: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "แนบเอกสารโครงการ (PDF)",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: _pickPDF,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.picture_as_pdf, color: Colors.red),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _fileName ?? "คลิกเพื่อเลือกไฟล์ PDF",
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
                                      icon: const Icon(Icons.close, size: 20),
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

                      SizedBox(height: 20),
                      CustomButton(
                        height: 55,
                        text: const Text(
                          "บันทึกฉบับร่าง",
                          style: TextStyle(color: Colors.white),
                        ),
                        border: 15,
                        color: Color(0xff3A6BB5),
                        onPressed:
                            () => showDialog(
                              context: context,
                              builder:
                                  (_) => AlertConfirmWidget(
                                    title: "คุณต้องการบันทึกฉบับร่างหรือไม่",
                                    onConfirm: () => _handleSave(isDraft: true),
                                  ),
                            ),
                      ),

                      SizedBox(height: 20),
                      CustomButton(
                        height: 55,
                        text: const Text(
                          "สร้างโครงการ",
                          style: TextStyle(color: Colors.white),
                        ),
                        border: 15,
                        color: Color(0xff3A9AB5),
                        onPressed:
                            () => showDialog(
                              context: context,
                              builder:
                                  (_) => AlertConfirmWidget(
                                    title: "คุณต้องการสร้างโครงการหรือไม่",
                                    onConfirm:
                                        () => _handleSave(isDraft: false),
                                  ),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
