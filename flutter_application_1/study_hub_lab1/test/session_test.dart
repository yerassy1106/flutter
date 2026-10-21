import 'package:flutter_test/flutter_test.dart';
import 'package:study_hub/models/session.dart';
import 'package:study_hub/models/subject.dart';

void main() {
  test('Session copies and protects its attendee list', () {
    final names = ['Aigerim'];
    final session = Session.withAttendees(
      id: 'test',
      title: 'Test session',
      subject: Subject.math,
      starts: DateTime(2026, 10, 22, 10),
      place: 'Room 1',
      limit: 2,
      online: false,
      attendees: names,
    );

    names.add('Dana');

    expect(session.attendees, ['Aigerim']);
    expect(() => session.attendees.add('Timur'), throwsUnsupportedError);
  });
}
