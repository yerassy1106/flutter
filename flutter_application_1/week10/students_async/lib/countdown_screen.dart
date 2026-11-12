import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

/// Level 4: a countdown, two ways.
class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int _version = 0; // 0 = A (StreamBuilder), 1 = B (listen + cancel)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('A: StreamBuilder')),
                ButtonSegment(value: 1, label: Text('B: listen')),
              ],
              selected: {_version},
              onSelectionChanged: (s) => setState(() => _version = s.first),
            ),
          ),
          Expanded(
            child: _version == 0 ? const _VersionA() : const _VersionB(),
          ),
        ],
      ),
    );
  }
}

/// Version A: StreamBuilder subscribes and cancels for us.
class _VersionA extends StatefulWidget {
  const _VersionA();

  @override
  State<_VersionA> createState() => _VersionAState();
}

class _VersionAState extends State<_VersionA> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _stream,
      builder: (context, snapshot) {
        return Center(
          child: Text(
            '${snapshot.data ?? 10}',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        );
      },
    );
  }
}

/// Version B: we subscribe, so we must cancel.
class _VersionB extends StatefulWidget {
  const _VersionB();

  @override
  State<_VersionB> createState() => _VersionBState();
}

class _VersionBState extends State<_VersionB> {
  int _left = 10;
  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((i) => setState(() => _left = i));
  }

  @override
  void dispose() {
    _sub.cancel(); // before super.dispose()
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$_left',
        style: Theme.of(context).textTheme.displayLarge,
      ),
    );
  }
}
