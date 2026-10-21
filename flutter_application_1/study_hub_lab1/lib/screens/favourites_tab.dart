import 'package:flutter/material.dart';

import '../models/session.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_list.dart';

/// Tab 2.
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onFavourite,
    required this.onBrowse,
  });

  final List<Session> sessions;
  final ValueChanged<Session> onOpen;
  final ValueChanged<String> onFavourite;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = [...sessions.where((s) => s.favourite)]
      ..sort((a, b) => a.starts.compareTo(b.starts));

    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        buttonLabel: 'Browse sessions',
        onPressed: onBrowse,
      );
    }
    return SessionList(
      sessions: favourites,
      onOpen: onOpen,
      onFavourite: onFavourite,
    );
  }
}
