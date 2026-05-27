import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n.dart';
import '../models/scan_document.dart';
import '../services/storage_service.dart';
import '../widgets/credits_bar.dart';
import 'edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ScanDocument> _docs = [];
  bool _loading = true;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final docs = await StorageService.loadAll();
    if (!mounted) return;
    setState(() {
      _docs = docs;
      _loading = false;
    });
  }

  Future<bool> _ensureCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;
    if (!mounted) return false;
    final l = L10n.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.permissionTitle),
        content: Text(l.permissionBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: Text(l.openSettings),
          ),
        ],
      ),
    );
    return false;
  }

  Future<void> _startScan() async {
    if (_scanning) return;
    final l = L10n.of(context);
    if (!await _ensureCamera()) return;

    setState(() => _scanning = true);
    List<String>? pictures;
    try {
      pictures = await CunningDocumentScanner.getPictures(
        noOfPages: 20,
        isGalleryImportAllowed: true,
      );
    } catch (_) {
      pictures = null;
    }
    if (!mounted) return;
    setState(() => _scanning = false);

    if (pictures == null || pictures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.scanFailed)),
      );
      return;
    }

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditScreen(imagePaths: pictures!)),
    );
    if (saved == true) _reload();
  }

  Future<void> _shareDoc(ScanDocument doc) async {
    final files = doc.files.map((f) => XFile(f)).toList();
    await Share.shareXFiles(files, subject: doc.title);
  }

  Future<void> _deleteDoc(ScanDocument doc) async {
    final l = L10n.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await StorageService.delete(doc);
      _reload();
    }
  }

  Future<void> _renameDoc(ScanDocument doc) async {
    final l = L10n.of(context);
    final controller = TextEditingController(text: doc.title);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.rename),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l.documentName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await StorageService.rename(doc.id, name);
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appName),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _docs.isEmpty
                    ? _EmptyState(l: l)
                    : RefreshIndicator(
                        onRefresh: _reload,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                          itemCount: _docs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) => _DocTile(
                            doc: _docs[i],
                            l: l,
                            onShare: () => _shareDoc(_docs[i]),
                            onDelete: () => _deleteDoc(_docs[i]),
                            onRename: () => _renameDoc(_docs[i]),
                          ),
                        ),
                      ),
          ),
          const CreditsBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanning ? null : _startScan,
        icon: _scanning
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.document_scanner),
        label: Text(l.scanNow),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l});
  final L10n l;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      children: [
        const SizedBox(height: 90),
        Icon(Icons.document_scanner_outlined,
            size: 88, color: scheme.primary.withOpacity(0.5)),
        const SizedBox(height: 16),
        Center(
          child: Text(
            l.noScansTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            l.noScansHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({
    required this.doc,
    required this.l,
    required this.onShare,
    required this.onDelete,
    required this.onRename,
  });
  final ScanDocument doc;
  final L10n l;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final date = DateFormat.yMMMd(l.lang).add_jm().format(doc.createdAt);
    return Card(
      child: InkWell(
        onTap: onShare,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 72,
                  child: File(doc.thumb).existsSync()
                      ? Image.file(File(doc.thumb), fit: BoxFit.cover)
                      : Container(
                          color: scheme.surfaceContainerHighest,
                          child: const Icon(Icons.image_not_supported_outlined),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            doc.isPdf ? 'PDF' : 'JPG',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(l.pagesCount(doc.pageCount),
                            style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(date,
                        style: TextStyle(
                            fontSize: 11, color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'share') onShare();
                  if (v == 'rename') onRename();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'share',
                    child: Row(children: [
                      const Icon(Icons.share, size: 20),
                      const SizedBox(width: 10),
                      Text(l.share),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(children: [
                      const Icon(Icons.edit_outlined, size: 20),
                      const SizedBox(width: 10),
                      Text(l.rename),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      const Icon(Icons.delete_outline, size: 20),
                      const SizedBox(width: 10),
                      Text(l.delete),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
