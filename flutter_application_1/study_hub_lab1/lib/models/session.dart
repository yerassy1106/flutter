import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'subject.dart';

/// The main model (R1): immutable, const constructor, copyWith.
@immutable
class Session {
  const Session({
    required this.id,
    required this.title,
    required this.subject,
    required this.starts,
    required this.place,
    required this.limit,
    required this.online,
    this.description,
    this.favourite = false,
  }) : _attendees = const [];

  /// Copies the supplied names so later changes to the caller's list cannot
  /// mutate this model.
  factory Session.withAttendees({
    required String id,
    required String title,
    required Subject subject,
    required DateTime starts,
    required String place,
    required int limit,
    required bool online,
    String? description,
    Iterable<String> attendees = const [],
    bool favourite = false,
  }) {
    return Session._(
      id: id,
      title: title,
      subject: subject,
      starts: starts,
      place: place,
      limit: limit,
      online: online,
      description: description,
      attendees: List<String>.unmodifiable(attendees),
      favourite: favourite,
    );
  }

  const Session._({
    required this.id,
    required this.title,
    required this.subject,
    required this.starts,
    required this.place,
    required this.limit,
    required this.online,
    required this.description,
    required List<String> attendees,
    required this.favourite,
  }) : _attendees = attendees;

  /// R3: defaults for a new item.
  factory Session.empty() {
    final now = DateTime.now();
    return Session.withAttendees(
      id: '',
      title: '',
      subject: Subject.math,
      starts: DateTime(now.year, now.month, now.day + 1, 18),
      place: '',
      limit: 10,
      online: false,
    );
  }

  /// How long a session lasts (used by the countdown and isPast).
  static const Duration length = Duration(hours: 2);

  final String id;
  final String title;
  final Subject subject;
  final DateTime starts;
  final String place;
  final int limit;

  /// Mode: when true, [place] is a link instead of a room.
  final bool online;

  /// Optional text, shown only when present.
  final String? description;
  final bool favourite;

  final List<String> _attendees;

  /// R1: read-only view, the list cannot be mutated from outside.
  List<String> get attendees => UnmodifiableListView(_attendees);

  // R4: derived values are getters, never fields.
  int get count => _attendees.length;
  int get freePlaces => limit > count ? limit - count : 0;
  bool get isFull => count >= limit;
  bool get isPast => starts.add(length).isBefore(DateTime.now());
  bool contains(String name) => _attendees.contains(name);

  /// R5: record getter.
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Session copyWith({
    String? id,
    String? title,
    Subject? subject,
    DateTime? starts,
    String? place,
    int? limit,
    bool? online,
    String? description,
    bool clearDescription = false,
    List<String>? attendees,
    bool? favourite,
  }) {
    return Session.withAttendees(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      starts: starts ?? this.starts,
      place: place ?? this.place,
      limit: limit ?? this.limit,
      online: online ?? this.online,
      description: clearDescription ? null : (description ?? this.description),
      attendees: attendees ?? _attendees,
      favourite: favourite ?? this.favourite,
    );
  }
}
