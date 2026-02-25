enum ProjectStatus {
  draft("ฉบับร่าง"),
  pending("รออนุมัติ"),
  approve("อนุมัติ"),
  rejected("ไม่อนุมัติ");

  final String label;
  const ProjectStatus(this.label);

  static String getLabel(int i) {
    return ProjectStatus.values[i - 1].label;
  }
}