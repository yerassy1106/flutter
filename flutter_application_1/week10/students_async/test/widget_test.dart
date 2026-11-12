import 'package:flutter_test/flutter_test.dart';
import 'package:students_async/main.dart';

void main() {
  testWidgets('home screen has three ways in', (tester) async {
    await tester.pumpWidget(const StudentsApp());

    expect(find.text('By hand'), findsOneWidget);
    expect(find.text('FutureBuilder'), findsOneWidget);
    expect(find.text('Countdown'), findsOneWidget);
  });
}
