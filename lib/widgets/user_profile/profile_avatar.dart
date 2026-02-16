import 'package:flutter/material.dart';
import 'package:srv_paperless/data/minio.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageName;
  final VoidCallback onTap;

  const ProfileAvatar({
    super.key,
    required this.imageName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          FutureBuilder<String>(
            future: getPrivateFileUrl(imageName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircleAvatar(
                  radius: 75,
                  child: CircularProgressIndicator(),
                );
              }

              final imageUrl = snapshot.data;

              return ClipOval(
                child: Image.network(
                  imageUrl ?? '',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/images/user.png",
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      width: 150,
                      height: 150,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 20,
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
