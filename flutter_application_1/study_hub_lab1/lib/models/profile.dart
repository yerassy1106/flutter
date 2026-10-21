import 'package:flutter/foundation.dart';

@immutable
class Profile {
  const Profile({required this.name, required this.group});

  /// R3
  const Profile.empty() : name = '', group = '';

  final String name;
  final String group;

  Profile copyWith({String? name, String? group}) {
    return Profile(name: name ?? this.name, group: group ?? this.group);
  }
}
