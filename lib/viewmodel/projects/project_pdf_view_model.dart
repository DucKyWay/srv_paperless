import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/minio.dart';

final projectPdfUrlProvider = FutureProvider.family<String?, String>((
  ref,
  pdfPath,
) async {
  if (pdfPath.isEmpty) return null;

  try {
    final url = await getPrivateFileUrl(pdfPath);
    return url.isEmpty ? null : url;
  } catch (e) {
    return null;
  }
});
