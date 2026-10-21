import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_hub/main.dart';

void main() {
  testWidgets('detail tabs work at phone size', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calculus office hours'));
    await tester.pumpAndSettle();

    expect(find.text('Room 204'), findsOneWidget);
    expect(find.text('Names (4)'), findsOneWidget);

    await tester.tap(find.text('Names (4)'));
    await tester.pumpAndSettle();

    expect(find.text('Aigerim'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
