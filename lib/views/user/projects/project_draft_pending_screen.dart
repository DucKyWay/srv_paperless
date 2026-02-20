import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:srv_paperless/data/model/project_model.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/viewmodel/project_view_model.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

class RequestDraftAndPendingScreen extends ConsumerStatefulWidget {
  const RequestDraftAndPendingScreen({super.key});

  @override
  ConsumerState<RequestDraftAndPendingScreen> createState() =>
      _RequestDraftAndPendingScreenState();
}

class _RequestDraftAndPendingScreenState
    extends ConsumerState<RequestDraftAndPendingScreen> {
  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    return MenuWidget(
      title: const HeaderWithBackButton(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/request/draft/create");
        },
        backgroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: SafeArea(
        child: Center(
          // ในเมธอด build
          child: Column(
            children: [
              const TitleNormal(title: "ร่างโครงการของฉัน"),
              // ใช้ Expanded ครอบ เพื่อให้ ListView มีขอบเขตความสูงที่ชัดเจน
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                  child: draftRequest(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget draftRequest(BuildContext context, WidgetRef ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.currentUser?.id ?? '';
  final draftProjects = ref.watch(draftProjectsProvider(userId));
  return draftProjects.when(
    data: (projects) {
      if (projects.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "คุณยังไม่มีรายการฉบับร่าง",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) => Card(context, projects[index]),
      );
    },
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) => Center(child: Text("เกิดข้อผิดพลาด: $err")),
  );
}

Widget Card(BuildContext context, Project project) {
  String formattedDate =
      project.date != null
          ? DateFormat('dd MMM yyyy').format(project.date!)
          : 'ไม่ระบุวันที่';
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    // เพิ่มระยะห่างระหว่าง Card
    width: MediaQuery.of(context).size.width * 0.85,
    padding: const EdgeInsets.all(12),
    // เพิ่ม padding ให้เนื้อหาไม่ชิดขอบ
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20), // ปรับความโค้งให้มนขึ้นตามรูป
      border: Border.all(color: Colors.black, width: 1.0),
    ),
    child: Row(
      children: [
        // --- ส่วนที่ 1: รูปภาพโปรไฟล์ (ด้านซ้าย) ---
        CircleAvatar(
          radius: 45,
          backgroundColor: Colors.blue[100],
          backgroundImage: const AssetImage('assets/images/user.png'),
        ),
        const SizedBox(width: 15), // ระยะห่างระหว่างรูปกับข้อความ
        // --- ส่วนที่ 2: ข้อมูลและปุ่ม (ด้านขวา) ---
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // ชิดซ้าย
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ชื่อโครงการ: ${project.projectName}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis, // ตัดคำถ้าชื่อยาวเกินไป
              ),
              const SizedBox(height: 4),
              Text(
                "ชื่อผู้ยื่นโครงการ : ${project.chairman}",
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                "ยื่นเมื่อ : $formattedDate",
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),

              // ปุ่มรายละเอียด
              SizedBox(
                width: double.infinity, // ให้ปุ่มขยายกว้างตามพื้นที่
                height: 35,
                child: ElevatedButton(
                  onPressed: () {
                    // Logic สำหรับดูรายละเอียด
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff76B947), // สีเขียวตามรูป
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "รายละเอียด",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
