import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/profile.dart';
import '../models/session.dart';
import '../routes.dart';
import '../widgets/dialogs.dart';
import 'favourites_tab.dart';
import 'list_tab.dart';
import 'profile_tab.dart';

/// R10: the item list and the profile live here; tabs get them as
/// constructor parameters and send changes up as callbacks.
class Shell extends StatefulWidget {
  const Shell({super.key, required this.themeMode, required this.onThemeMode});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeMode;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  static const _titles = ['Sessions', 'Favourites', 'Profile'];

  int _tab = 0;
  List<Session> _sessions = buildSeed();
  Profile _profile = const Profile.empty();

  // ---- state changes (R12: setState wraps the change only) ----

  void _toggleFavourite(String id) {
    setState(() {
      _sessions = [
        for (final s in _sessions)
          s.id == id ? s.copyWith(favourite: !s.favourite) : s,
      ];
    });
  }

  void _upsert(Session session) {
    final exists = _sessions.any((s) => s.id == session.id);
    setState(() {
      _sessions = exists
          ? [for (final s in _sessions) s.id == session.id ? session : s]
          : [session, ..._sessions];
    });
  }

  void _delete(String id) {
    setState(() => _sessions = _sessions.where((s) => s.id != id).toList());
  }

  void _setProfile(Profile profile) => setState(() => _profile = profile);

  /// R28: tab switches from tabs or pushed screens go through here.
  void _goToTab(int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _tab = index);
  }

  // ---- navigation ----

  void _open(Session session) {
    Navigator.of(context).pushNamed<void>(
      Routes.detail,
      arguments: DetailArgs(
        session: session,
        userName: _profile.name,
        onChanged: _upsert,
        onDelete: _delete,
        onOpenProfile: () => _goToTab(2),
      ),
    );
  }

  /// R27: await `pushNamed<Session>`, check null and mounted, then setState.
  Future<void> _add() async {
    final created = await Navigator.of(
      context,
    ).pushNamed<Session>(Routes.form, arguments: const FormArgs());
    if (created == null || !mounted) {
      return;
    }
    _upsert(created);
  }

  // ---- drawer (R32) ----

  void _showAbout() {
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'StudyHub - find and join study sessions.\n'
          'Mobile Development, Lab 1. All data lives in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    Navigator.of(context).pop();
    final ok = await confirm(
      context,
      title: 'Reset data?',
      message: 'The sample sessions come back and your profile is cleared.',
      confirmLabel: 'Reset',
    );
    if (!ok || !mounted) {
      return;
    }
    setState(() {
      _sessions = buildSeed();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('StudyHub', style: theme.textTheme.titleLarge),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: _showAbout,
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Reset data'),
                onTap: _resetData,
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          ListTab(
            sessions: _sessions,
            onOpen: _open,
            onFavourite: _toggleFavourite,
          ),
          FavouritesTab(
            sessions: _sessions,
            onOpen: _open,
            onFavourite: _toggleFavourite,
            onBrowse: () => _goToTab(0),
          ),
          ProfileTab(
            profile: _profile,
            sessions: _sessions,
            themeMode: widget.themeMode,
            onProfile: _setProfile,
            onThemeMode: widget.onThemeMode,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: _add,
              tooltip: 'New session',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
