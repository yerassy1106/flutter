import 'package:flutter/material.dart';

class TapCard extends StatefulWidget {
  const TapCard({super.key});

  @override
  State<TapCard> createState() => _TapCardState();
}

class _TapCardState extends State<TapCard> {
  int taps = 0;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: () {
        setState(() {
          taps++;
        });
      },
      onLongPress: () async {
        final res = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Reset the counter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Reset'),
              ),
            ],
          ),
        );
        if (res == true) {
          setState(() {
            taps = 0;
          });
        }
      },
      child: ListTile(
        title: Text('Tap this card'),
        trailing: Text('$taps taps'),
      ),
    ),
  );
}
