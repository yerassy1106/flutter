import 'package:flutter/foundation.dart';

import 'models/session.dart';

/// R25: the only place with route-name literals.
abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

/// R26: the detail gets the item AND callbacks through route arguments.
class DetailArgs {
  const DetailArgs({
    required this.session,
    required this.userName,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final Session session;
  final String userName;
  final ValueChanged<Session> onChanged;
  final ValueChanged<String> onDelete;
  final VoidCallback onOpenProfile;
}

/// R26: the form receives Session? (null = new) and returns a Session via pop.
class FormArgs {
  const FormArgs({this.session});

  final Session? session;
}
