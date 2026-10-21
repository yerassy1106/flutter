import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();
  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;
  int _passwordLength = 0;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthText]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day.$month.${d.year}';
  }

  Future<void> _pickBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _birth = picked;
      _birthText.text = _formatDate(picked);
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Account created')));
      setState(() => _done = true);
    }
  }

  void _startOver() {
    setState(() {
      for (final c in [_name, _email, _password, _confirm, _birthText]) {
        c.clear();
      }
      _group = null;
      _birth = null;
      _agreed = false;
      _passwordLength = 0;
      _done = false;
    });
  }

  Widget _buildForm() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (v) =>
                (v ?? '').trim().length < 2 ? 'Name is too short' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _email,
            focusNode: _emailFocus,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'name@kbtu.kz',
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (v) {
              final s = (v ?? '').trim();
              final at = s.indexOf('@');
              if (at < 1 || !s.substring(at + 1).contains('.')) {
                return 'Email looks wrong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(
              labelText: 'Password',
              helperText: 'At least 8 characters',
            ),
            obscureText: true,
            textInputAction: TextInputAction.next,
            onChanged: (v) => setState(() => _passwordLength = v.length),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (v) =>
                (v ?? '').length < 8 ? 'Password is too short' : null,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_passwordLength of 8',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirm,
            decoration: const InputDecoration(labelText: 'Confirm password'),
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: _agreed ? (_) => _submit() : null,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (v) {
              final s = v ?? '';
              if (s.isEmpty) return 'Repeat the password';
              return s != _password.text ? 'Passwords do not match' : null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _group,
            decoration: const InputDecoration(labelText: 'Group'),
            items: [
              for (final g in groups)
                DropdownMenuItem(value: g, child: Text(g)),
            ],
            onChanged: (g) => setState(() => _group = g),
            validator: (g) => g == null ? 'Choose a group' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _birthText,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Date of birth',
              hintText: 'dd.mm.yyyy',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: _pickBirth,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (_) => _birth == null ? 'Pick a date of birth' : null,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            title: const Text('I agree to the rules'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _agreed ? _submit : null,
            child: const Text('Sign up'),
          ),
        ],
      ),
    ),
  );

  Widget _buildSummary() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SummaryCard(
          name: _name.text.trim(),
          email: _email.text.trim(),
          group: _group ?? '',
          birth: _birthText.text,
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: _startOver, child: const Text('Start over')),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: _done ? _buildSummary() : _buildForm(),
  );
}
