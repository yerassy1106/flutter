import 'package:flutter/material.dart';

import '../models/session.dart';
import 'session_card.dart';

/// R20: list on phones, grid from 600 px - decided by LayoutBuilder.
class SessionList extends StatelessWidget {
  const SessionList({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Session> sessions;
  final ValueChanged<Session> onOpen;
  final ValueChanged<String> onFavourite;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget card(Session s) => SessionCard(
          session: s,
          onTap: () => onOpen(s),
          onFavourite: () => onFavourite(s.id),
        );

        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent: 136,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: sessions.length,
            itemBuilder: (context, index) => card(sessions[index]),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => card(sessions[index]),
        );
      },
    );
  }
}
