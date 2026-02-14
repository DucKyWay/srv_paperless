import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srv_paperless/widgets/custom_text_field.dart';
import 'package:srv_paperless/widgets/main_layout.dart';
import 'package:srv_paperless/widgets/menu_header.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CreateRequest extends StatefulWidget {
  const CreateRequest({super.key});

  @override
  State<CreateRequest> createState() => _CreateRequestState();
}

class _CreateRequestState extends State<CreateRequest> {
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController projectChairmanController =
      TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController requestCreateDateController =
      TextEditingController();
  String? _fileName;
  File? _selectedFile;

  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
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
                    // จัดรูปแบบเป็น 14/02/2026
                    requestCreateDateController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(newDateTime);
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




  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    requestCreateDateController.text = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.now());
    return MainLayout(
      title: NormalHeader(),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                Container(
                  padding:EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/srv-logo.png",
                        fit: BoxFit.contain,
                      ),
                      Text(
                        "ยื่นโครงการ",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "นโยบายและแผนงาน โรงเรียนสารวิทยา",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
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
                              padding:  EdgeInsets.symmetric(
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
                                   Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red,
                                  ),
                                   SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _fileName ?? "คลิกเพื่อเลือกไฟล์ PDF",
                                      style: TextStyle(
                                        color: _fileName == null
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
