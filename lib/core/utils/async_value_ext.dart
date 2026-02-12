import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueExt on AsyncValue<dynamic> {
  String get labelText => value?.label ?? "ไม่พบข้อมูล";
}