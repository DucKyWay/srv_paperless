import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:minio/minio.dart';
import 'package:minio/io.dart';

final minio = Minio(
  endPoint: dotenv.env['B2_END_POINT']!,
  accessKey: dotenv.env['B2_KEY_ID']!,
  secretKey: dotenv.env['B2_APPLICATION_KEY']!,
  useSSL: true,
  port: 443,
  region: 'us-west-004',
);

Future<bool> checkB2Connection() async {
  final String targetBucket = 'srv-paperless';
  try {
    final bool exists = await minio.bucketExists(targetBucket);
    
    if (exists) {
      print("Connect to Backblaze: Bucket '$targetBucket' is ready.");
      return true;
    } else {
      print("Connection Failed: Bucket '$targetBucket' not found.");
      return false;
    }
  } catch (e) {
    print("Connection Failed: $e");
    return false;
  }
}

Future<void> uploadFile(
  String bucketName,
  String objectName,
  String filePath,
) async {
  try {
    await minio.fPutObject(bucketName, objectName, filePath);
    print("Upload successful!");
  } catch (e) {
    print("Upload failed: $e");
  }
}

Future<String> getPrivateImageUrl(String fileName) async {
  if (fileName == null || fileName.isEmpty || fileName == "user.png") return "";
  try {
    return await minio.presignedGetObject('srv-paperless', fileName, expires: 3600);
  } catch (e) {
    print("Error generating URL: $e");
    return "";
  }
}

Future<void> deleteFile(String bucketName, String objectName) async {
  try {
    if (objectName == "user.png" || objectName.isEmpty) return;

    await minio.removeObject(bucketName, objectName);
    print("Delete successful: $objectName");
  } catch (e) {
    print("Delete failed: $e");
  }
}