class Request {
  String? uid;
  String? projectName;
  String? chairman;
  String? date;
  double? budget;
  String? pdfPath;
  String status; // 'draft' หรือ 'submitted'

  Request({
    this.projectName,
    this.chairman,
    this.date,
    this.budget,
    this.pdfPath,
    this.status = 'draft',
  });
}