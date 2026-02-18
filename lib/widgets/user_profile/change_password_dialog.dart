import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/services/auth_service.dart';
import 'package:srv_paperless/widgets/custom_button.dart';

class ChangePasswordDialog extends ConsumerWidget {
  const ChangePasswordDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    return AlertDialog(
      title: const Center(child: Text("เปลี่ยนรหัสผ่านใหม่", style: TextStyle(fontWeight: FontWeight.bold))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "รหัสผ่านใหม่"),
          ),
          TextField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "ยืนยันรหัสผ่านใหม่"),
          ),
        ],
      ),
      actions: [
        CustomButton(
          onPressed: () async {
            if (newPasswordController.text == confirmPasswordController.text &&
                newPasswordController.text.isNotEmpty) {
              try {
                await ref
                    .read(authServiceProvider)
                    .changePassword(newPasswordController.text);

                if (context.mounted) {
                  Navigator.pop(context); // ปิด Dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("เปลี่ยนรหัสผ่านสำเร็จ"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("รหัสผ่านไม่ตรงกัน"),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          text: const Text("บันทึก", style: TextStyle(color: Colors.white),),
          color: Color(0xFF1D4200),
          height: 55,
          border: 15,
        ),
        SizedBox(height: 8),
        CustomButton(
          onPressed: () => Navigator.pop(context),
          text: const Text("ยกเลิก", style: TextStyle(color: Colors.white),),
          color: Theme.of(context).colorScheme.onErrorContainer,
          height: 55,
          border: 15,
        ),
      ],
    );
  }
}
