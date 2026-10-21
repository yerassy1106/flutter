import 'package:flutter/material.dart';

import '../models/session.dart';
import '../utils/format.dart';

/// R18: the one reusable card.
class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onFavourite,
  });

  final Session session;
  final VoidCallback onTap;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = session;
    final accent = s.subject.color(scheme);

    // R19: "FULL", "N left" when <= 5 remain, otherwise no badge.
    final String? badge = s.isFull
        ? 'FULL'
        : (s.freePlaces <= 5 ? '${s.freePlaces} left' : null);

    return Opacity(
      opacity: s.isPast ? 0.6 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: accent.withValues(alpha: 0.18),
                      child: Icon(s.subject.icon, color: accent),
                    ),
                    if (badge != null)
                      Positioned(
                        left: -8,
                        right: -8,
                        bottom: -8,
                        child: Center(
                          child: _Badge(text: badge, full: s.isFull),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatDateTime(s.starts),
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        s.place,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onFavourite,
                  tooltip: s.favourite ? 'Remove favourite' : 'Add favourite',
                  icon: Icon(
                    s.favourite ? Icons.favorite : Icons.favorite_border,
                    color: s.favourite ? scheme.error : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.full});

  final String text;
  final bool full;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: full ? scheme.error : scheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: full ? scheme.onError : scheme.onPrimary,
        ),
      ),
    );
  }
}
