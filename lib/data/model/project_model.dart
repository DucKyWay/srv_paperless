class Project {
  String? id;
  String? projectName;
  String? chairman;
  String? date;
  double? budget;
  String? pdfPath;
  String? fixLasted;
  String status; // 'draft' หรือ 'submitted'

  Project({
    required this.id,
    required this.projectName,
    required this.chairman,
    required this.date,
    required this.budget,
    required this.pdfPath,
    required this.fixLasted,
    this.status = 'draft',
  });


  Project copyWith({
    String? id,
    String? projectName,
    String? chairman,
    String? date,
    double? budget,
    String? pdfPath,
    String? fixLasted,
    String? status,
  }){
    return Project(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      chairman: chairman ?? this.chairman,
      date: date?? this.date,
      budget: budget?? this.budget,
      pdfPath: pdfPath ?? this.pdfPath,
      fixLasted:  fixLasted ?? this.fixLasted,
      status: status ?? this.status,
    );
  }



factory Project.fromMap(Map<String,dynamic> map,String  docId){
  return Project(
    id: docId, 
    projectName: map['projectName']?.toString() ?? '', 
    chairman: map['chairman']?.toString() ?? '', 
    date: map['date']?.toString() ?? '', 
    budget: map['budget']?? 0, 
    pdfPath: map['pdfPath'] ?? '', 
    fixLasted: map['fixLasted'] ?? '',
    status: map['status']?.toString() ??'draft',
    );
}

Map<String,dynamic> toMap(){
  return {
    'projectName' : projectName,
    'chairman' : chairman,
    'date' :date,
    'budget' : budget,
    'pdfPath' : pdfPath,
    'fixLasted' : fixLasted,
    'status' : status 
  };
}

}
