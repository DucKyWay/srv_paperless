class BudgetYear {
  final String? id;
  final int year;
  final bool thisYear;

  BudgetYear({this.id, required this.year, required this.thisYear});

  BudgetYear copyWith({String? id, int? year, bool? thisYear}) {
    return BudgetYear(
      id: id ?? this.id,
      year: year ?? this.year,
      thisYear: thisYear ?? this.thisYear,
    );
  }

  factory BudgetYear.fromMap(Map<String, dynamic> map, String docId) {
    return BudgetYear(id: docId, year: map['year'], thisYear: map['this_year']);
  }

  Map<String, dynamic> toMap() {
    return {'year': year, 'this_year': thisYear};
  }
}
