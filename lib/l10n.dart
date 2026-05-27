import 'package:flutter/widgets.dart';

/// Lightweight map-based localization (English + Bahasa Indonesia).
class L10n {
  L10n(this.lang);
  final String lang;

  static L10n of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_L10nScope>();
    return scope?.l10n ?? L10n('en');
  }

  String _t(String key) => _values[key]?[lang] ?? _values[key]?['en'] ?? key;

  String get appName => _t('appName');
  String get tagline => _t('tagline');
  String get dayBadge => _t('dayBadge');
  String get chooseLanguage => _t('chooseLanguage');
  String get continueBtn => _t('continueBtn');
  String get recentScans => _t('recentScans');
  String get noScansTitle => _t('noScansTitle');
  String get noScansHint => _t('noScansHint');
  String get scanNow => _t('scanNow');
  String get enhance => _t('enhance');
  String get original => _t('original');
  String get autoMode => _t('autoMode');
  String get grayscale => _t('grayscale');
  String get blackWhite => _t('blackWhite');
  String get saveAsPdf => _t('saveAsPdf');
  String get saveAsImage => _t('saveAsImage');
  String get share => _t('share');
  String get delete => _t('delete');
  String get deleteConfirm => _t('deleteConfirm');
  String get cancel => _t('cancel');
  String get processing => _t('processing');
  String get savedTitle => _t('savedTitle');
  String get permissionTitle => _t('permissionTitle');
  String get permissionBody => _t('permissionBody');
  String get openSettings => _t('openSettings');
  String get scanFailed => _t('scanFailed');
  String get noPages => _t('noPages');
  String get createdBy => _t('createdBy');
  String get page => _t('page');
  String get pdfDoc => _t('pdfDoc');
  String get imageDoc => _t('imageDoc');
  String get rename => _t('rename');
  String get documentName => _t('documentName');
  String get save => _t('save');

  String pageOf(int a, int b) =>
      lang == 'id' ? 'Halaman $a dari $b' : 'Page $a of $b';
  String pagesCount(int n) => lang == 'id' ? '$n halaman' : '$n pages';

  static const Map<String, Map<String, String>> _values = {
    'appName': {'en': 'Scan No Ads', 'id': 'Scan No Ads'},
    'tagline': {
      'en': 'Scan documents. No ads. Forever.',
      'id': 'Pindai dokumen. Tanpa iklan. Selamanya.',
    },
    'dayBadge': {
      'en': '365 Days App Challenge · Day 3',
      'id': '365 Days App Challenge · Hari 3',
    },
    'chooseLanguage': {'en': 'Choose your language', 'id': 'Pilih bahasa'},
    'continueBtn': {'en': 'Continue', 'id': 'Lanjut'},
    'recentScans': {'en': 'Recent scans', 'id': 'Pindaian terbaru'},
    'noScansTitle': {'en': 'No scans yet', 'id': 'Belum ada pindaian'},
    'noScansHint': {
      'en': 'Tap the button below to scan your first document.',
      'id': 'Ketuk tombol di bawah untuk memindai dokumen pertama.',
    },
    'scanNow': {'en': 'Scan', 'id': 'Pindai'},
    'enhance': {'en': 'Enhance', 'id': 'Tingkatkan'},
    'original': {'en': 'Original', 'id': 'Asli'},
    'autoMode': {'en': 'Auto', 'id': 'Otomatis'},
    'grayscale': {'en': 'Grayscale', 'id': 'Abu-abu'},
    'blackWhite': {'en': 'B&W', 'id': 'Hitam Putih'},
    'saveAsPdf': {'en': 'Save PDF', 'id': 'Simpan PDF'},
    'saveAsImage': {'en': 'Save JPG', 'id': 'Simpan JPG'},
    'share': {'en': 'Share', 'id': 'Bagikan'},
    'delete': {'en': 'Delete', 'id': 'Hapus'},
    'deleteConfirm': {
      'en': 'Delete this document?',
      'id': 'Hapus dokumen ini?',
    },
    'cancel': {'en': 'Cancel', 'id': 'Batal'},
    'processing': {'en': 'Processing…', 'id': 'Memproses…'},
    'savedTitle': {'en': 'Saved', 'id': 'Tersimpan'},
    'permissionTitle': {'en': 'Camera permission', 'id': 'Izin kamera'},
    'permissionBody': {
      'en': 'Camera access is needed to scan documents. Please grant permission in settings.',
      'id': 'Akses kamera diperlukan untuk memindai dokumen. Mohon berikan izin di pengaturan.',
    },
    'openSettings': {'en': 'Open settings', 'id': 'Buka pengaturan'},
    'scanFailed': {
      'en': 'Scan was cancelled or failed.',
      'id': 'Pemindaian dibatalkan atau gagal.',
    },
    'noPages': {'en': 'No pages captured.', 'id': 'Tidak ada halaman.'},
    'createdBy': {
      'en': 'Created by: Ir. Riovan Styx Roring',
      'id': 'Dibuat oleh: Ir. Riovan Styx Roring',
    },
    'page': {'en': 'Page', 'id': 'Halaman'},
    'pdfDoc': {'en': 'PDF document', 'id': 'Dokumen PDF'},
    'imageDoc': {'en': 'Image', 'id': 'Gambar'},
    'rename': {'en': 'Rename', 'id': 'Ganti nama'},
    'documentName': {'en': 'Document name', 'id': 'Nama dokumen'},
    'save': {'en': 'Save', 'id': 'Simpan'},
  };
}

class L10nScope extends StatelessWidget {
  const L10nScope({super.key, required this.lang, required this.child});
  final String lang;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _L10nScope(l10n: L10n(lang), child: child);
  }
}

class _L10nScope extends InheritedWidget {
  const _L10nScope({required this.l10n, required super.child});
  final L10n l10n;

  @override
  bool updateShouldNotify(_L10nScope oldWidget) => oldWidget.l10n.lang != l10n.lang;
}
