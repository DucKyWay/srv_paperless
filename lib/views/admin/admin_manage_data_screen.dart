import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/viewmodel/academic_department_view_model.dart';
import 'package:srv_paperless/viewmodel/divisions_view_model.dart';
import 'package:srv_paperless/viewmodel/employee_status_view_model.dart';
import 'package:srv_paperless/widgets/custom_text_field.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

import '../../viewmodel/config_crud.dart';
import '../../widgets/alert_confirm_widget.dart';
import '../../widgets/custom_button.dart';

enum ConfigMode {
  academicDepartment(label: "กลุ่มสาระการเรียนรู้"),
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
  ConfigCrud _notifier() {
    switch (widget.mode) {
      case ConfigMode.academicDepartment:
        return ref.read(academicDepartmentProvider.notifier);
      case ConfigMode.divisions:
        return ref.read(divisionsProvider.notifier);
      case ConfigMode.employeeStatus:
        return ref.read(employeeStatusProvider.notifier);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = _itemsProvider(ref, widget.mode);

    return MenuWidget(
      title: HeaderWithBackButton(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddDialog(),
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
                  TitleNormal(title: "จัดการข้อมูล", des: widget.mode.label),
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
                        // Edit
                        () => _showEditDialog(it),
                        // Delete
                        () => showDialog(
                          context: context,
                          builder:
                              (_) => AlertConfirmWidget(
                                title:
                                    "คุณต้องการลบ ${widget.mode.label + it.label} หรือไม่",
                                onConfirm: () {
                                  _notifier().deleteItem(it.id);
                                  Navigator.pop(context);
                                },
                              ),
                        ),
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
                      .map(
                        (d) =>
                            ConfigItem(id: d.id!, key: d.key, label: d.label),
                      )
                      .toList(),
            );

      case ConfigMode.academicDepartment:
        return ref
            .watch(allAcademicDepartment)
            .whenData(
              (list) =>
                  list
                      .map(
                        (ad) => ConfigItem(
                          id: ad.id!,
                          key: ad.key,
                          label: ad.label,
                        ),
                      )
                      .toList(),
            );

      case ConfigMode.employeeStatus:
        return ref
            .watch(allEmployeeStatus)
            .whenData(
              (list) =>
                  list
                      .map(
                        (es) => ConfigItem(
                          id: es.id!,
                          key: es.key,
                          label: es.label,
                        ),
                      )
                      .toList(),
            );
    }
  }

  Future<void> _showAddDialog() async {
    final keyController = TextEditingController();
    final labelController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("เพิ่ม${widget.mode.label}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: "Key", controller: keyController),
              SizedBox(height: 8),
              CustomTextField(label: "Label", controller: labelController),
            ],
          ),
          actions: [
            CancelAndConfirmRowWidget(
              onConfirm: () async {
                await _notifier().createItem(
                  keyController.text,
                  labelController.text,
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(ConfigItem item) async {
    final labelController = TextEditingController(text: item.label);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("แก้ไข${widget.mode.label}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: "Label", controller: labelController),
            ],
          ),
          actions: [
            CancelAndConfirmRowWidget(
              onConfirm: () async {
                await _notifier().updateItem(
                  item.id,
                  item.key,
                  labelController.text,
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
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
  final String key;
  final String label;

  const ConfigItem({required this.id, required this.key, required this.label});
}
