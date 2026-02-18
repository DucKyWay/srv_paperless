class Project_location {
  String? id;
  String? requestId;
  String? locationPathImage;
  String? locationImageDetail; 

  Project_location({
    required this.id,
    required this.requestId,
    required this.locationPathImage,
    required this.locationImageDetail,
  });


  Project_location copyWith({
    String? id,
    String? requestId,
    String? locationPathImage,
    String? locationImageDetail,
  }){
    return Project_location(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      locationPathImage: locationPathImage ?? this.locationPathImage,
      locationImageDetail: locationImageDetail?? this.locationImageDetail,
    );
  }



factory Project_location.fromMap(Map<String,dynamic> map,String  docId){
  return Project_location(
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
