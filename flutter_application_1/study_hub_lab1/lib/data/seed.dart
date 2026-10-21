import '../models/session.dart';
import '../models/subject.dart';

const _people = [
  'Aigerim', 'Dana', 'Timur', 'Madina', 'Alikhan', 'Sofia', //
  'Arman', 'Laura', 'Nurlan', 'Aya', 'Daniyar', 'Zhanna',
];

List<String> _names(int n) => _people.take(n).toList();

/// Twelve seed items, dates relative to today.
List<Session> buildSeed() {
  final now = DateTime.now();
  DateTime at(int days, int hour, [int minute = 0]) =>
      DateTime(now.year, now.month, now.day + days, hour, minute);

  return [
    Session.withAttendees(
      id: 's1',
      title: 'Calculus office hours',
      subject: Subject.math,
      starts: at(1, 10),
      place: 'Room 204',
      limit: 12,
      online: false,
      description: 'Bring your problem sets and questions.',
      attendees: _names(4),
    ),
    Session.withAttendees(
      id: 's2',
      title: 'Flutter widgets crash course',
      subject: Subject.coding,
      starts: at(2, 15),
      place: 'Lab 3.1',
      limit: 8,
      online: false,
      description: 'Layouts, state and navigation in two hours.',
      attendees: _names(5),
      favourite: true,
    ),
    // Mandatory: a 60-character title.
    Session.withAttendees(
      id: 's3',
      title: 'Intensive Linear Algebra and Differential Equations Marathon',
      subject: Subject.math,
      starts: at(3, 9),
      place: 'Main hall',
      limit: 30,
      online: false,
      description: 'A long revision day before the exam.',
      attendees: _names(9),
    ),
    // Mandatory: an item at its limit.
    Session.withAttendees(
      id: 's4',
      title: 'Spanish conversation club',
      subject: Subject.languages,
      starts: at(3, 17, 30),
      place: 'Library cafe',
      limit: 6,
      online: false,
      description: 'Relaxed speaking practice.',
      attendees: _names(6),
    ),
    // Mandatory: a past item.
    Session.withAttendees(
      id: 's5',
      title: 'Organic chemistry lab prep',
      subject: Subject.science,
      starts: at(-2, 14),
      place: 'Lab 1.2',
      limit: 15,
      online: false,
      attendees: _names(9),
    ),
    // Mandatory: mode on (place is a link) and no optional text.
    Session.withAttendees(
      id: 's6',
      title: 'UI design critique',
      subject: Subject.design,
      starts: at(4, 12),
      place: 'https://meet.example.org/ui-critique',
      limit: 30,
      online: true,
      attendees: _names(8),
    ),
    Session.withAttendees(
      id: 's7',
      title: 'IELTS speaking practice',
      subject: Subject.languages,
      starts: at(5, 16),
      place: 'Room 118',
      limit: 10,
      online: false,
      description: 'Mock interviews in pairs.',
      attendees: _names(8),
      favourite: true,
    ),
    Session.withAttendees(
      id: 's8',
      title: 'Python for data analysis',
      subject: Subject.coding,
      starts: at(6, 19),
      place: 'https://meet.example.org/python-data',
      limit: 40,
      online: true,
      description: 'pandas basics with a small dataset.',
      attendees: _names(12),
    ),
    // Started 40 minutes ago, nobody on the list yet.
    Session.withAttendees(
      id: 's9',
      title: 'Probability problem solving',
      subject: Subject.math,
      starts: now.subtract(const Duration(minutes: 40)),
      place: 'Room 310',
      limit: 20,
      online: false,
      description: 'Dice, cards and Bayes.',
    ),
    Session.withAttendees(
      id: 's10',
      title: 'Physics lab report help',
      subject: Subject.science,
      starts: at(-5, 13),
      place: 'Lab 2.4',
      limit: 10,
      online: false,
      description: 'How to write the error analysis section.',
      attendees: _names(6),
    ),
    Session.withAttendees(
      id: 's11',
      title: 'Figma basics workshop',
      subject: Subject.design,
      starts: at(9, 14),
      place: 'Studio B',
      limit: 13,
      online: false,
      description: 'Frames, auto layout and components.',
      attendees: _names(11),
    ),
    Session.withAttendees(
      id: 's12',
      title: 'Data structures study group',
      subject: Subject.coding,
      starts: at(10, 18),
      place: 'Room 207',
      limit: 25,
      online: false,
      description: 'Trees and graphs, weekly.',
      attendees: _names(7),
    ),
  ];
}
