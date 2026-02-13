import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSheet extends StatelessWidget {
  final Function(ImageSource) onSourceSelected;

  const ImageSourceSheet({super.key, required this.onSourceSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('ถ่ายรูปใหม่'),
            onTap: () {
              Navigator.pop(context);
              onSourceSelected(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('เลือกจากแกลเลอรี่'),
            onTap: () {
              Navigator.pop(context);
              onSourceSelected(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}