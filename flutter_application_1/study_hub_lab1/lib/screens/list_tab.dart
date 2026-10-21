import 'package:flutter/material.dart';

import '../models/session.dart';
import '../models/subject.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_list.dart';

/// Tab 1. R21: search + chips + filter in one Column, list in Expanded.
class ListTab extends StatefulWidget {
  const ListTab({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Session> sessions;
  final ValueChanged<Session> onOpen;
  final ValueChanged<String> onFavourite;

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  final _search = TextEditingController();
  String _query = '';
  Subject? _subject;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// R7: where + sort on a copy; past items last; state is never sorted.
  List<Session> get _visible {
    final q = _query.trim().toLowerCase();
    final filtered = widget.sessions.where(
      (s) =>
          (_showPast || !s.isPast) &&
          (_subject == null || s.subject == _subject) &&
          (q.isEmpty || s.title.toLowerCase().contains(q)),
    );
    return [...filtered]..sort((a, b) {
      if (a.isPast != b.isPast) {
        return a.isPast ? 1 : -1;
      }
      return a.starts.compareTo(b.starts);
    });
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _search,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search sessions',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearSearch,
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _subject == null,
                onSelected: (_) => setState(() => _subject = null),
              ),
              for (final subject in Subject.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: Icon(subject.icon, size: 18),
                  label: Text(subject.label),
                  selected: _subject == subject,
                  onSelected: (_) => setState(() => _subject = subject),
                ),
              ],
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Show past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: items.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No sessions match',
                  buttonLabel: 'Clear search',
                  onPressed: _clearSearch,
                )
              : SessionList(
                  sessions: items,
                  onOpen: widget.onOpen,
                  onFavourite: widget.onFavourite,
                ),
        ),
      ],
    );
  }
}
