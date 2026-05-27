import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

enum EnhanceMode { original, auto, grayscale, blackWhite }

class _EnhanceJob {
  const _EnhanceJob(this.path, this.mode);
  final String path;
  final int mode;
}

Uint8List _runEnhanceJob(_EnhanceJob job) {
  final bytes = File(job.path).readAsBytesSync();
  return ImageService.enhanceBytes(bytes, EnhanceMode.values[job.mode]);
}

class ImageService {
  /// Decode, apply enhancement, and re-encode as JPEG bytes on a worker isolate.
  static Future<Uint8List> enhanceFile(String path, EnhanceMode mode) {
    return compute(_runEnhanceJob, _EnhanceJob(path, mode.index));
  }

  static Uint8List enhanceBytes(Uint8List bytes, EnhanceMode mode) {
    img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    // Downscale very large captures to keep PDFs reasonable.
    if (decoded.width > 2200) {
      decoded = img.copyResize(decoded, width: 2200);
    }

    switch (mode) {
      case EnhanceMode.original:
        break;
      case EnhanceMode.auto:
        decoded = img.adjustColor(
          decoded,
          contrast: 1.18,
          brightness: 1.04,
          saturation: 1.06,
        );
        break;
      case EnhanceMode.grayscale:
        decoded = img.grayscale(decoded);
        break;
      case EnhanceMode.blackWhite:
        decoded = img.grayscale(decoded);
        for (final p in decoded) {
          final v = p.r > 135 ? 255 : 0;
          p.setRgb(v, v, v);
        }
        break;
    }

    return img.encodeJpg(decoded, quality: 88);
  }

  /// Build a small thumbnail JPEG from already-enhanced bytes.
  static Uint8List makeThumb(Uint8List jpgBytes, {int width = 320}) {
    final decoded = img.decodeImage(jpgBytes);
    if (decoded == null) return jpgBytes;
    final resized = decoded.width > width
        ? img.copyResize(decoded, width: width)
        : decoded;
    return img.encodeJpg(resized, quality: 80);
  }
}
