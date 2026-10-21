import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/session.dart';
import '../models/subject.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/dialogs.dart';

/// What the form looked like when it opened (compared by R30).
typedef _Snapshot = ({
  String title,
  String place,
  String limit,
  String description,
  Subject? subject,
  bool online,
  DateTime? starts,
});

/// One screen for new and edit. Receives Session?, returns a Session (R26).
class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // R33
  final _formKey = GlobalKey<FormState>();

  // R35: controllers and focus nodes are fields, created once, disposed.
  late final TextEditingController _title;
  late final TextEditingController _place;
  late final TextEditingController _limit;
  late final TextEditingController _description;
  late final TextEditingController _dateText;
  late final TextEditingController _timeText;
  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  Subject? _subject;
  late bool _online;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;
  bool _allowDiscardPop = false;
  late final _Snapshot _initial;

  bool get _editing => widget.args.session != null;

  @override
  void initState() {
    super.initState();
    final s = widget.args.session ?? Session.empty();
    _title = TextEditingController(text: s.title);
    _place = TextEditingController(text: s.place);
    _limit = TextEditingController(text: '${s.limit}');
    _description = TextEditingController(text: s.description ?? '');
    _dateText = TextEditingController(text: formatDate(s.starts));
    _timeText = TextEditingController(text: formatTime(s.starts));
    _subject = _editing ? s.subject : null;
    _online = s.online;
    _date = DateTime(s.starts.year, s.starts.month, s.starts.day);
    _time = TimeOfDay(hour: s.starts.hour, minute: s.starts.minute);
    _initial = _snapshot;
  }

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _limit.dispose();
    _description.dispose();
    _dateText.dispose();
    _timeText.dispose();
    _titleFocus.dispose();
    _placeFocus.dispose();
    _limitFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  // ---- derived values ----

  DateTime? get _starts {
    final d = _date;
    final t = _time;
    if (d == null || t == null) {
      return null;
    }
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  _Snapshot get _snapshot => (
    title: _title.text,
    place: _place.text,
    limit: _limit.text,
    description: _description.text,
    subject: _subject,
    online: _online,
    starts: _starts,
  );

  /// R30: current values vs. the ones the form opened with.
  bool get _dirty => _snapshot != _initial;

  // ---- validators (R34) ----

  String? _validateTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 3) {
      return 'At least 3 characters';
    }
    if (text.length > 60) {
      return 'At most 60 characters';
    }
    return null;
  }

  String? _validatePlace(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return _online ? 'Meeting link is required' : 'Place is required';
    }
    if (_online && !text.contains('://')) {
      return 'A link must contain ://';
    }
    return null;
  }

  String? _validateLimit(String? value) {
    final n = int.tryParse(value?.trim() ?? '');
    if (n == null) {
      return 'Enter a whole number';
    }
    if (n < 1 || n > 500) {
      return 'Between 1 and 500';
    }
    final current = widget.args.session?.count ?? 0;
    if (_editing && n < current) {
      return 'Not below the current count ($current)';
    }
    return null;
  }

  String? _validateSubject(Subject? value) {
    return value == null ? 'Pick a category' : null;
  }

  String? _validateDate(String? value) {
    return _date == null ? 'Pick a date' : null;
  }

  String? _validateTime(String? value) {
    if (_time == null) {
      return 'Pick a time';
    }
    final starts = _starts;
    if (!_editing && starts != null && !starts.isAfter(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  // ---- pickers (R36) ----

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null || !mounted) {
      return; // Cancel keeps the old value.
    }
    _dateText.text = formatDate(picked);
    setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) {
      return;
    }
    _timeText.text = formatHm(picked.hour, picked.minute);
    setState(() => _time = picked);
  }

  void _dismissKeyboard(PointerDownEvent event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // ---- save (R17) ----

  Session _build() {
    final base = widget.args.session ?? Session.empty();
    final text = _description.text.trim();
    return base.copyWith(
      id: base.id.isEmpty
          ? DateTime.now().microsecondsSinceEpoch.toString()
          : base.id,
      title: _title.text.trim(),
      subject: _subject ?? base.subject,
      starts: _starts ?? base.starts,
      place: _place.text.trim(),
      limit: int.tryParse(_limit.text.trim()) ?? base.limit,
      online: _online,
      description: text,
      clearDescription: text.isEmpty,
    );
  }

  Future<void> _save() async {
    if (_saving) {
      return; // a double tap does not save twice
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(_build());
  }

  @override
  Widget build(BuildContext context) {
    // R30: the arrow and the Android gesture both end up here.
    return PopScope(
      canPop: !_dirty || _allowDiscardPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        final discard = await confirm(
          context,
          title: 'Discard changes?',
          message: 'Your edits will be lost.',
          confirmLabel: 'Discard',
        );
        if (!discard || !mounted) {
          return;
        }
        setState(() => _allowDiscardPop = true);
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) {
          return;
        }
        navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_editing ? 'Edit session' : 'New session')),
        // R37: the form scrolls, no Spacer inside the scroll view.
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () => setState(() {}),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  focusNode: _titleFocus,
                  maxLength: 60,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateTitle,
                  onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Subject>(
                  initialValue: _subject,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final s in Subject.values)
                      DropdownMenuItem(value: s, child: Text(s.label)),
                  ],
                  validator: _validateSubject,
                  onChanged: (value) => setState(() => _subject = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online session'),
                  subtitle: const Text('The place becomes a meeting link'),
                  value: _online,
                  onChanged: (value) => setState(() => _online = value),
                ),
                TextFormField(
                  controller: _place,
                  focusNode: _placeFocus,
                  keyboardType: _online
                      ? TextInputType.url
                      : TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: _online ? 'Meeting link' : 'Place',
                    border: const OutlineInputBorder(),
                  ),
                  validator: _validatePlace,
                  onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _limit,
                  focusNode: _limitFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Places (limit)',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateLimit,
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateText,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _timeText,
                        readOnly: true,
                        onTap: _pickTime,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          suffixIcon: Icon(Icons.schedule),
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  focusNode: _descriptionFocus,
                  maxLines: 3,
                  maxLength: 200,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => null,
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
