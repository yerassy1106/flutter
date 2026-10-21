import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birth,
  });

  final String name;
  final String email;
  final String group;
  final String birth;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      ListTile(
        leading: const Icon(Icons.person),
        title: Text(name),
        subtitle: const Text('Name'),
      ),
      ListTile(
        leading: const Icon(Icons.email),
        title: Text(email),
        subtitle: const Text('Email'),
      ),
      ListTile(
        leading: const Icon(Icons.group),
        title: Text(group),
        subtitle: const Text('Group'),
      ),
      ListTile(
        leading: const Icon(Icons.cake),
        title: Text(birth),
        subtitle: const Text('Date of birth'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 600;
        return Card(
          child: wide
              ? GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  childAspectRatio: 4,
                  physics: const NeverScrollableScrollPhysics(),
                  children: tiles,
                )
              : Column(mainAxisSize: MainAxisSize.min, children: tiles),
        );
      },
    );
  }
}
