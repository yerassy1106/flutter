import 'package:flutter/material.dart';
import 'data.dart';
import 'info_row.dart';
import 'profile_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ProfileHeader(
                name: myName,
                university: myUniversity,
              ),
              const SizedBox(height: 32),
              for (final fact in facts)
                InfoRow(
                  label: fact.label,
                  value: fact.value,
                ),
            ],
          ),
        ),
      ),
    );
  }
}