import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashing_widget/flashing_widget.dart';

void main() {
  group('FlashingWidget Tests', () {
    testWidgets('FlashingWidget creates without error', (
      WidgetTester tester,
    ) async {
      bool onTapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashingWidget(
              onTap: () {
                onTapCalled = true;
              },
              child: const Text('Test Widget'),
            ),
          ),
        ),
      );

      expect(find.text('Test Widget'), findsOneWidget);
      expect(onTapCalled, false);
    });

    testWidgets('FlashingWidget responds to tap', (WidgetTester tester) async {
      bool onTapCalled = false;
      bool beforeFlashingCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashingWidget(
              onTap: () {
                onTapCalled = true;
              },
              beforeFlashing: () {
                beforeFlashingCalled = true;
              },
              flashDuration: const Duration(milliseconds: 10),
              flashCount: 2,
              child: const Text('Test Widget'),
            ),
          ),
        ),
      );

      // Tap the widget
      await tester.tap(find.text('Test Widget'));
      await tester.pump();

      expect(beforeFlashingCalled, true);

      // Wait for flashing to complete
      await tester.pump(const Duration(milliseconds: 50));
      expect(onTapCalled, true);
    });

    testWidgets('FlashingWidget shows child widget', (
      WidgetTester tester,
    ) async {
      const testChild = Text('Child Widget');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FlashingWidget(onTap: () {}, child: testChild)),
        ),
      );

      expect(find.text('Child Widget'), findsOneWidget);
    });
  });
}
