import 'package:flutter/material.dart';

/// Category of a study session (enhanced enum: label + icon).
enum Subject {
  math('Math', Icons.functions),
  coding('Coding', Icons.code),
  languages('Languages', Icons.translate),
  science('Science', Icons.science_outlined),
  design('Design', Icons.palette_outlined);

  const Subject(this.label, this.icon);

  final String label;
  final IconData icon;

  /// R2: exhaustive switch expression -> a colorScheme role.
  Color color(ColorScheme scheme) => switch (this) {
    Subject.math => scheme.primary,
    Subject.coding => scheme.secondary,
    Subject.languages => scheme.tertiary,
    Subject.science => scheme.error,
    Subject.design => scheme.onSurfaceVariant,
  };
}
