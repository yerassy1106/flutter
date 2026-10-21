import 'package:flutter/material.dart';

import 'models/session.dart';
import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';

/// R25: builds detail and form from typed argument classes.
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.detail:
      if (settings.arguments case final DetailArgs args) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => DetailScreen(args: args),
        );
      }
    case Routes.form:
      if (settings.arguments case final FormArgs args) {
        return MaterialPageRoute<Session>(
          settings: settings,
          builder: (context) => FormScreen(args: args),
        );
      }
  }
  return null;
}

Route<dynamic> onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (context) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('Not found')),
    ),
  );
}
