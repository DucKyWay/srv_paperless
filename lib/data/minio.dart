import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:minio/minio.dart';
import 'package:minio/io.dart';

final String bucketName = "srv-paperless";
final minio = Minio(
  endPoint: dotenv.env['B2_END_POINT']!,
  accessKey: dotenv.env['B2_KEY_ID']!,
  secretKey: dotenv.env['B2_APPLICATION_KEY']!,
  useSSL: true,
  port: 443,
  region: 'us-west-004',
);

Future<bool> checkB2Connection() async {
  try {
    final bool exists = await minio.bucketExists(bucketName);

    if (exists) {
      debugPrint("Connect to Backblaze: Bucket '$bucketName' is ready.");
      return true;
    } else {
      debugPrint("Connection Failed: Bucket '$bucketName' not found.");
      return false;
    }
  } catch (e) {
    debugPrint("Connection Failed: $e");
    return false;
  }
}

Future<void> uploadFile(String objectName, String filePath) async {
  try {
    await minio.fPutObject(bucketName, objectName, filePath);
    debugPrint("Upload successful!");
  } catch (e) {
    debugPrint("Upload failed: $e");
  }
}

Future<void> deleteFile(String objectName) async {
  if (objectName.isEmpty) return;
  try {
    await minio.removeObject(bucketName, objectName);
    debugPrint("Delete successful: $objectName");
  } catch (e) {
    debugPrint("Delete failed: $e");
  }
}

Future<String> getPrivateFileUrl(String fileName) async {
  if (fileName.isEmpty) return "";
  try {
    return await minio.presignedGetObject(bucketName, fileName, expires: 3600);
  } catch (e) {
    debugPrint("B2 Error: Object '$fileName' does not exist in bucket.");
    return "";
  }
}

Future<void> deleteOldUserProfileImages(String uid) async {
  try {
    final prefix = "profile_${uid}_";
    
    await for (var result in minio.listObjectsV2(bucketName, prefix: prefix)) {
      final deleteKeys = result.objects
          .map((obj) => obj.key)
          .whereType<String>()
          .toList();

      if (deleteKeys.isNotEmpty) {
        await minio.removeObjects(bucketName, deleteKeys);
        debugPrint("Deleted ${deleteKeys.length} files for user $uid");
      }
    }
  } catch (e) {
    debugPrint("Error deleting old images: $e");
  }
}