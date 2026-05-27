import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n.dart';

const _tiktok = 'https://www.tiktok.com/@ir.riovansroring';
const _instagram = 'https://www.instagram.com/ir.riovansroring/';
const _youtube = 'https://youtube.com/@ir.riovanroring';

class CreditsBar extends StatelessWidget {
  const CreditsBar({super.key});

  Future<void> _open(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // Silently ignore: no browser / app available.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.createdBy,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _SocialButton(
                icon: Icons.music_note,
                tooltip: 'TikTok',
                onTap: () => _open(_tiktok),
              ),
              _SocialButton(
                icon: Icons.camera_alt_outlined,
                tooltip: 'Instagram',
                onTap: () => _open(_instagram),
              ),
              _SocialButton(
                icon: Icons.play_circle_outline,
                tooltip: 'YouTube',
                onTap: () => _open(_youtube),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onTap,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
