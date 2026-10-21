import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/session.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

/// R9: exhaustive switch over the sealed class.
String _countdownText(Countdown c) => switch (c) {
  Upcoming(:final left) => 'Starts in ${formatDuration(left)}',
  Started(:final since) => 'Started ${formatDuration(since)} ago',
  Ended() => 'Ended',
};

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Session _s = widget.args.session;
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // R13: one-minute timer, created here, cancelled in dispose.
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) {
        return;
      }
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---- actions ----

  /// R15: the primary action asks first; empty name -> SnackBar.
  Future<void> _join() async {
    final name = widget.args.userName;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter your name in the profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: widget.args.onOpenProfile,
          ),
        ),
      );
      return;
    }
    final ok = await confirm(
      context,
      title: 'Join this session?',
      message: '${_s.title}\n${formatDateTime(_s.starts)}',
      confirmLabel: 'Join',
    );
    if (!ok || !mounted) {
      return;
    }
    final updated = _s.copyWith(attendees: [..._s.attendees, name]);
    setState(() => _s = updated);
    widget.args.onChanged(updated);
  }

  void _leave() {
    final name = widget.args.userName;
    final updated = _s.copyWith(
      attendees: [
        for (final n in _s.attendees)
          if (n != name) n,
      ],
    );
    setState(() => _s = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _edit() async {
    final edited = await Navigator.of(
      context,
    ).pushNamed<Session>(Routes.form, arguments: FormArgs(session: _s));
    if (edited == null || !mounted) {
      return;
    }
    setState(() => _s = edited);
    widget.args.onChanged(edited);
  }

  Future<void> _delete() async {
    final ok = await confirm(
      context,
      title: 'Delete session?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!ok || !mounted) {
      return;
    }
    widget.args.onDelete(_s.id);
    Navigator.of(context).pop();
  }

  Future<void> _onMenu(_MenuAction action) async {
    switch (action) {
      case _MenuAction.edit:
        await _edit();
      case _MenuAction.delete:
        await _delete();
    }
  }

  // ---- pieces ----

  Widget _header(ColorScheme scheme) {
    final accent = _s.subject.color(scheme);
    final countdown = Countdown.of(_s, _now);

    return AspectRatio(
      aspectRatio: 16 / 7,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/header.png',
            fit: BoxFit.cover,
            color: accent,
            colorBlendMode: BlendMode.modulate,
          ),
          Center(child: Icon(_s.subject.icon, size: 64, color: scheme.surface)),
          Positioned(left: 12, top: 12, child: _Pill(_s.subject.label)),
          Positioned(
            right: 12,
            top: 12,
            child: _Pill(_countdownText(countdown)),
          ),
        ],
      ),
    );
  }

  Widget _about() {
    // R5: the record is destructured where it is shown.
    final (:taken, :free) = _s.places;

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.event),
          title: Text(formatDateTime(_s.starts)),
        ),
        ListTile(
          leading: Icon(_s.online ? Icons.link : Icons.place_outlined),
          title: Text(_s.place),
        ),
        ListTile(
          leading: const Icon(Icons.people_outline),
          title: Text('$taken taken, $free free (limit ${_s.limit})'),
        ),
        // R6: optional text via collection if, no "!".
        if (_s.description case final text?)
          ListTile(leading: const Icon(Icons.notes), title: Text(text)),
      ],
    );
  }

  Widget _names(ColorScheme scheme) {
    if (_s.attendees.isEmpty) {
      return const EmptyState(
        icon: Icons.group_outlined,
        message: 'Nobody has joined yet',
      );
    }
    final me = widget.args.userName;

    return ListView(
      children: _s.attendees.map((n) {
        return ListTile(
          tileColor: n == me ? scheme.primaryContainer : null,
          leading: CircleAvatar(child: Text(n.isEmpty ? '' : n[0])),
          title: Text(
            n == me ? '$n (You)' : n,
            style: n == me
                ? const TextStyle(fontWeight: FontWeight.bold)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _actionBar() {
    final name = widget.args.userName;
    final joined = name.isNotEmpty && _s.contains(name);

    // R16: null when it cannot act; the opposite once you are on the list.
    final VoidCallback? onPressed = joined
        ? _leave
        : (_s.isFull ? null : _join);

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(joined ? 'Leave' : (_s.isFull ? 'Full' : 'Join')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // R29: DefaultTabController + TabBar + TabBarView; live count in label.
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // R31: no back arrow written by hand; the menu holds Edit/Delete.
        appBar: AppBar(
          title: Text(_s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: _onMenu,
              itemBuilder: (context) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _header(scheme),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Names (${_s.count})'),
              ],
            ),
            Expanded(child: TabBarView(children: [_about(), _names(scheme)])),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _actionBar(),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: theme.textTheme.labelMedium),
    );
  }
}
