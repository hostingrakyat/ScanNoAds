import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/scan_document.dart';

class StorageService {
  static const _prefsKey = 'scan_documents_v1';

  static Future<Directory> _scansDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'scans'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<List<ScanDocument>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List)
        .map((e) => ScanDocument.fromJson(e as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static Future<void> _persist(List<ScanDocument> docs) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(docs.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  static Future<ScanDocument> savePdf({
    required String title,
    required Uint8List pdfBytes,
    required Uint8List thumbBytes,
    required int pageCount,
  }) async {
    final dir = await _scansDir();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final pdfPath = p.join(dir.path, '$id.pdf');
    final thumbPath = p.join(dir.path, '${id}_thumb.jpg');
    await File(pdfPath).writeAsBytes(pdfBytes);
    await File(thumbPath).writeAsBytes(thumbBytes);

    final doc = ScanDocument(
      id: id,
      title: title,
      type: 'pdf',
      files: [pdfPath],
      thumb: thumbPath,
      pageCount: pageCount,
      createdAt: DateTime.now(),
    );
    final all = await loadAll();
    all.insert(0, doc);
    await _persist(all);
    return doc;
  }

  static Future<ScanDocument> saveImages({
    required String title,
    required List<Uint8List> pages,
    required Uint8List thumbBytes,
  }) async {
    final dir = await _scansDir();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final files = <String>[];
    for (var i = 0; i < pages.length; i++) {
      final imgPath = p.join(dir.path, '${id}_$i.jpg');
      await File(imgPath).writeAsBytes(pages[i]);
      files.add(imgPath);
    }
    final thumbPath = p.join(dir.path, '${id}_thumb.jpg');
    await File(thumbPath).writeAsBytes(thumbBytes);

    final doc = ScanDocument(
      id: id,
      title: title,
      type: 'image',
      files: files,
      thumb: thumbPath,
      pageCount: pages.length,
      createdAt: DateTime.now(),
    );
    final all = await loadAll();
    all.insert(0, doc);
    await _persist(all);
    return doc;
  }

  static Future<void> rename(String id, String title) async {
    final all = await loadAll();
    final idx = all.indexWhere((d) => d.id == id);
    if (idx == -1) return;
    all[idx] = all[idx].copyWith(title: title);
    await _persist(all);
  }

  static Future<void> delete(ScanDocument doc) async {
    for (final f in [...doc.files, doc.thumb]) {
      final file = File(f);
      if (await file.exists()) {
        await file.delete();
      }
    }
    final all = await loadAll();
    all.removeWhere((d) => d.id == doc.id);
    await _persist(all);
  }
}
