import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final String mode;
  const AdminManageDataScreen({super.key, required this.mode});

  @override
  ConsumerState<AdminManageDataScreen> createState() => _AdminManageDataScreenState();
}

class _AdminManageDataScreenState extends ConsumerState<AdminManageDataScreen> {
  @override
  Widget build(BuildContext context) {
    return MenuWidget(
      title: HeaderWithBackButton(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {},
      ),
      child: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TitleNormal(),
              _card(context, "test", Colors.blue.shade800, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    String label,
    Color buttonColor,
    VoidCallback onPressed,
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
              color: Colors.red.shade800,
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon: Icon(Icons.delete),
              color: Colors.white,
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
