import 'package:flutter/material.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppBrowser {
  static Future<void> launch(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }
}

class InAppBrowserButton extends StatelessWidget {
  final String? url;
  final String? label;
  final Color? color;

  const InAppBrowserButton({super.key, this.url, this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: Text(
        label ?? "เปิดเอกสาร",
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      color: color ?? Colors.blue.shade700,
      onPressed: () {
        if (url != null && url!.isNotEmpty) {
          InAppBrowser.launch(url!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("ไม่พบเอกสาร"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}
