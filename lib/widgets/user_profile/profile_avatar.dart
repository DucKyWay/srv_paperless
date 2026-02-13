import 'package:flutter/material.dart';
import 'package:srv_paperless/data/minio.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageName;
  final VoidCallback onTap;

  const ProfileAvatar({super.key, required this.imageName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          FutureBuilder<String>(
            future: getPrivateImageUrl(imageName),
            builder: (context, snapshot) {
              final imageUrl = snapshot.data;
              return CircleAvatar(
                radius: 75,
                backgroundColor: Colors.grey[200],
                backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                    ? NetworkImage(imageUrl) as ImageProvider
                    : const AssetImage("assets/images/user.png"),
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const CircularProgressIndicator()
                    : null,
              );
            },
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 20,
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}