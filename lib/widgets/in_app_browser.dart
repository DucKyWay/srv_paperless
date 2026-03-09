import 'package:flutter/material.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppBrowserButton extends StatelessWidget {
  final String? url;

  const InAppBrowserButton({super.key, this.url});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: Text("เปิดเอกสาร", style: TextStyle(color: Colors.white)),
      color: Colors.blue.shade700,
      onPressed: () {
        if (url != null) {
          _launchURL(url!);
        } else {
          _showSnackBar(context, "ไม่พบเอกสาร", Colors.red);
        }
      },
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showSnackBar(
    BuildContext context,
    String text,
    Color color,
  ) {
    return ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
  }
}
