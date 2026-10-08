import 'package:flutter/material.dart';

class TwoWayCounter extends StatefulWidget {
  const TwoWayCounter({super.key});

  @override
  State<TwoWayCounter> createState() => _TwoWayCounterState();
}

class _TwoWayCounterState extends State<TwoWayCounter> {
  int count = 0;
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: count == 0
                  ? null
                  : () {
                      setState(() {
                        count--;
                      });
                    },
              child: const Text('-'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('$count', style: const TextStyle(fontSize: 20)),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  count++;
                });
              },
              child: const Text('+'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: saving
              ? null
              : () async {
                  setState(() {
                    saving = true;
                  });

                  await Future.delayed(const Duration(seconds: 2));

                  if (!mounted) return;

                  setState(() {
                    saving = false;
                  });

                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Saved')));
                },
          child: saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}