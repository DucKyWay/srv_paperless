import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/viewmodel/academic_department_view_model.dart';
import 'package:srv_paperless/viewmodel/divisions_view_model.dart';
import 'package:srv_paperless/viewmodel/employee_status_view_model.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

enum ConfigMode {
  academicDepartment(label: "กลุ่มสาระ"),
  divisions(label: "ฝ่ายงาน"),
  employeeStatus(label: "ตำแหน่ง");

  final String label;
  const ConfigMode({required this.label});
}

class AdminManageDataScreen extends ConsumerStatefulWidget {
  final ConfigMode mode;
  const AdminManageDataScreen({super.key, required this.mode});

  @override
  ConsumerState<AdminManageDataScreen> createState() =>
      _AdminManageDataScreenState();
}

class _AdminManageDataScreenState extends ConsumerState<AdminManageDataScreen> {
  @override
  Widget build(BuildContext context) {
    final itemsAsync = _itemsProvider(ref, widget.mode);

    return MenuWidget(
      title: HeaderWithBackButton(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          //TODO: add new item
        },
      ),
      child: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("เกิดข้อผิดพลาด: $e")),
        data: (items) {
          return SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TitleNormal(title: widget.mode.label, des: "จัดการข้อมูล"),
                  const SizedBox(height: 8),

                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text("ไม่พบข้อมูล"),
                    )
                  else
                    ...items.map(
                      (it) => _card(
                        context,
                        it.label,
                        () { // Edit
                          // TODO: edit
                        },
                        () { // Delete
                          //TODO: delete + it.id
                        },
                      ),
                    ),
                  SizedBox(height: 96),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  AsyncValue<List<ConfigItem>> _itemsProvider(WidgetRef ref, ConfigMode mode) {
    switch (mode) {
      case ConfigMode.divisions:
        return ref
            .watch(allDivisions)
            .whenData(
              (list) =>
                  list
                      .map((d) => ConfigItem(id: d.id, label: d.label ?? "-"))
                      .toList(),
            );

      case ConfigMode.academicDepartment:
        return ref
            .watch(allAcademicDepartment)
            .whenData(
              (list) =>
                  list
                      .map((a) => ConfigItem(id: a.id!, label: a.label ?? "-"))
                      .toList(),
            );

      case ConfigMode.employeeStatus:
        return ref
            .watch(allEmployeeStatus)
            .whenData(
              (list) =>
                  list
                      .map((s) => ConfigItem(id: s.id, label: s.label ?? "-"))
                      .toList(),
            );
    }
  }

  Widget _card(
    BuildContext context,
    String label,
    VoidCallback onPressedEdit,
    VoidCallback onPressedDelete,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black45, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow.shade800,
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon: Icon(Icons.edit),
              color: Colors.white,
              onPressed: onPressedEdit,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.red.shade800,
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon: Icon(Icons.delete),
              color: Colors.white,
              onPressed: onPressedDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class ConfigItem {
  final String id;
  final String label;
  const ConfigItem({required this.id, required this.label});
}
