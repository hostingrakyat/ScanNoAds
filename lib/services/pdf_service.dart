import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  /// Build a multi-page PDF where each page contains one image (full bleed,
  /// preserving aspect ratio).
  static Future<Uint8List> buildFromImages(List<Uint8List> pages) async {
    final doc = pw.Document();
    for (final bytes in pages) {
      final image = pw.MemoryImage(bytes);
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(16),
          build: (context) => pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
        ),
      );
    }
    return doc.save();
  }
}
