import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signup_form/main.dart';

void main() {
  testWidgets('empty form shows errors under the fields', (tester) async {
    await tester.pumpWidget(const MyApp());

    final agree = find.byType(CheckboxListTile);
    await tester.ensureVisible(agree);
    await tester.tap(agree);
    await tester.pump();

    final button = find.byType(FilledButton);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    expect(find.text('Name is too short'), findsOneWidget);
    expect(find.text('Choose a group'), findsOneWidget);
  });
}
