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
      print("Connect to Backblaze: Bucket '$bucketName' is ready.");
      return true;
    } else {
      print("Connection Failed: Bucket '$bucketName' not found.");
      return false;
    }
  } catch (e) {
    print("Connection Failed: $e");
    return false;
  }
}

Future<void> uploadFile(String objectName, String filePath) async {
  try {
    await minio.fPutObject(bucketName, objectName, filePath);
    print("Upload successful!");
  } catch (e) {
    print("Upload failed: $e");
  }
}

Future<void> deleteFile(String objectName) async {
  if (objectName.isEmpty) return;
  try {
    await minio.removeObject(bucketName, objectName);
    print("Delete successful: $objectName");
  } catch (e) {
    print("Delete failed: $e");
  }
}

Future<String> getPrivateFileUrl(String fileName) async {
  if (fileName.isEmpty) return "";
  try {
    return await minio.presignedGetObject(bucketName, fileName, expires: 3600);
  } catch (e) {
    print("B2 Error: Object '$fileName' does not exist in bucket.");
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
        print("Deleted ${deleteKeys.length} files for user $uid");
      }
    }
  } catch (e) {
    print("Error deleting old images: $e");
  }
}