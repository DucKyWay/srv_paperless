class ProjectLocation {
  String? id;
  String? requestId;
  String? locationPathImage;
  String? locationImageDetail; 

  ProjectLocation({
    required this.id,
    required this.requestId,
    required this.locationPathImage,
    required this.locationImageDetail,
  });


  ProjectLocation copyWith({
    String? id,
    String? requestId,
    String? locationPathImage,
    String? locationImageDetail,
  }){
    return ProjectLocation(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      locationPathImage: locationPathImage ?? this.locationPathImage,
      locationImageDetail: locationImageDetail?? this.locationImageDetail,
    );
  }



factory ProjectLocation.fromMap(Map<String,dynamic> map,String  docId){
  return ProjectLocation(
    id: docId, 
    requestId: map['requestId']?.toString() ?? '', 
    locationPathImage: map['locationPathImage']?.toString() ?? '', 
    locationImageDetail: map['locationImageDetail']?.toString() ?? '', 
    );
}

Map<String,dynamic> toMap(){
  return {
    'requestId' : requestId,
    'locationPathImage' : locationPathImage,
    'locationImageDetail' :locationImageDetail,
  };
}

}
