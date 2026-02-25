import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectLocation {
  String? id;
  String? requestId;
  String? locationImagePath;
  String? locationImageDetail;
  GeoPoint? location;

  ProjectLocation({
    required this.id,
    required this.requestId,
    required this.locationImagePath,
    required this.locationImageDetail,
    required this.location,
  });

  ProjectLocation copyWith({
    String? id,
    String? requestId,
    String? locationImagePath,
    String? locationImageDetail,
    GeoPoint? location,
  }) {
    return ProjectLocation(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      locationImagePath: locationImagePath ?? this.locationImagePath,
      locationImageDetail: locationImageDetail ?? this.locationImageDetail,
      location: location ?? this.location,
    );
  }

  factory ProjectLocation.fromMap(Map<String, dynamic> map, String docId) {
    return ProjectLocation(
      id: docId,
      requestId: map['request_id']?.toString() ?? '',
      locationImagePath: map['location_image_path']?.toString() ?? '',
      locationImageDetail: map['location_image_detail']?.toString() ?? '',
      location: map['location'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'request_id': requestId,
      'location_image_path': locationImagePath,
      'location_image_detail': locationImageDetail,
      'location': location,
    };
  }
}
