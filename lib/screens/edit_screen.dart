import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n.dart';
import '../models/scan_document.dart';
import '../services/image_service.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key, required this.imagePaths});
  final List<String> imagePaths;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _controller = PageController();
  final Map<String, Uint8List> _cache = {};
  EnhanceMode _mode = EnhanceMode.auto;
  int _page = 0;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _key(int page, EnhanceMode mode) => '$page-${mode.index}';

  Future<Uint8List> _preview(int page) async {
    final k = _key(page, _mode);
    final cached = _cache[k];
    if (cached != null) return cached;
    final bytes = await ImageService.enhanceFile(widget.imagePaths[page], _mode);
    _cache[k] = bytes;
    return bytes;
  }

  Future<List<Uint8List>> _enhanceAll() async {
    final result = <Uint8List>[];
    for (var i = 0; i < widget.imagePaths.length; i++) {
      result.add(await _preview(i));
    }
    return result;
  }

  String _defaultTitle() =>
      'Scan ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}';

  Future<void> _saveAsPdf() async {
    if (_saving) return;
    setState(() => _saving = true);
    final l = L10n.of(context);
    try {
      final pages = await _enhanceAll();
      final pdf = await PdfService.buildFromImages(pages);
      final thumb = ImageService.makeThumb(pages.first);
      final doc = await StorageService.savePdf(
        title: _defaultTitle(),
        pdfBytes: pdf,
        thumbBytes: thumb,
        pageCount: pages.length,
      );
      if (!mounted) return;
      _onSaved(doc, l);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveAsImages() async {
    if (_saving) return;
    setState(() => _saving = true);
    final l = L10n.of(context);
    try {
      final pages = await _enhanceAll();
      final thumb = ImageService.makeThumb(pages.first);
      final doc = await StorageService.saveImages(
        title: _defaultTitle(),
        pages: pages,
        thumbBytes: thumb,
      );
      if (!mounted) return;
      _onSaved(doc, l);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _onSaved(ScanDocument doc, L10n l) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l.savedTitle}: ${doc.title}'),
        action: SnackBarAction(
          label: l.share,
          onPressed: () => Share.shareXFiles(
            doc.files.map((f) => XFile(f)).toList(),
            subject: doc.title,
          ),
        ),
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final total = widget.imagePaths.length;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l.pageOf(_page + 1, total)),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: total,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) {
                    return FutureBuilder<Uint8List>(
                      future: _preview(i),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return InteractiveViewer(
                          maxScale: 4,
                          child: Center(
                            child: Image.memory(snap.data!),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              _FilterRow(
                mode: _mode,
                l: l,
                onChanged: (m) => setState(() => _mode = m),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _saving ? null : _saveAsImages,
                          icon: const Icon(Icons.image_outlined),
                          label: Text(l.saveAsImage),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _saveAsPdf,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: Text(l.saveAsPdf),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_saving)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(l.processing,
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.mode,
    required this.l,
    required this.onChanged,
  });
  final EnhanceMode mode;
  final L10n l;
  final ValueChanged<EnhanceMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <(EnhanceMode, String, IconData)>[
      (EnhanceMode.auto, l.autoMode, Icons.auto_fix_high),
      (EnhanceMode.original, l.original, Icons.image),
      (EnhanceMode.grayscale, l.grayscale, Icons.gradient),
      (EnhanceMode.blackWhite, l.blackWhite, Icons.contrast),
    ];
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (m, label, icon) = items[i];
          final selected = m == mode;
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onChanged(m),
            child: Container(
              width: 76,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: selected ? Colors.white : Colors.white12,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      size: 22,
                      color: selected ? Colors.black : Colors.white),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: selected ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
