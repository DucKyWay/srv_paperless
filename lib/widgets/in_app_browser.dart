import 'package:flutter/material.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppBrowserButton extends StatelessWidget {
  final String url;

  const InAppBrowserButton({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: Text("เปิดเอกสาร", style: TextStyle(color: Colors.white)),
      color: Colors.blue.shade700,
      onPressed: () {
        _launchURL(url);
      },
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
