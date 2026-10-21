import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/session.dart';

/// Tab 3. R38: controllers initialised from the model, save on onSubmitted.
class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.sessions,
    required this.themeMode,
    required this.onProfile,
    required this.onThemeMode,
  });

  final Profile profile;
  final List<Session> sessions;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfile;
  final ValueChanged<ThemeMode> onThemeMode;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static final _groupPattern = RegExp(r'^[A-Za-z]{2,5}-\d{3,4}$');

  late final TextEditingController _name;
  late final TextEditingController _group;
  final _groupKey = GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The profile can change from above (Reset data in the drawer).
    if (_name.text != widget.profile.name) {
      _name.text = widget.profile.name;
    }
    if (_group.text != widget.profile.group) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  String? _validateGroup(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || _groupPattern.hasMatch(text)) {
      return null;
    }
    return 'Use a format like CS-2301';
  }

  void _saveName(String value) {
    widget.onProfile(widget.profile.copyWith(name: value.trim()));
  }

  void _saveGroup(String value) {
    if (_groupKey.currentState?.validate() ?? false) {
      widget.onProfile(widget.profile.copyWith(group: value.trim()));
    }
  }

  String _modeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.profile.name;
    // R38: computed from the list on every build.
    final lists = name.isEmpty
        ? 0
        : widget.sessions.fold(
            0,
            (count, session) => count + (session.contains(name) ? 1 : 0),
          );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          controller: _name,
          maxLength: 30,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Name',
            helperText: 'Press the keyboard button to save',
            border: OutlineInputBorder(),
          ),
          onFieldSubmitted: _saveName,
          onTapOutside: (event) =>
              FocusManager.instance.primaryFocus?.unfocus(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: _groupKey,
          controller: _group,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateGroup,
          decoration: const InputDecoration(
            labelText: 'Group',
            hintText: 'CS-2301',
            border: OutlineInputBorder(),
          ),
          onFieldSubmitted: _saveGroup,
          onTapOutside: (event) =>
              FocusManager.instance.primaryFocus?.unfocus(),
        ),
        const SizedBox(height: 24),
        Text('You are on $lists lists', style: theme.textTheme.titleMedium),
        const SizedBox(height: 24),
        Text('Theme', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(_modeLabel(mode)),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeMode(mode),
              ),
          ],
        ),
      ],
    );
  }
}
