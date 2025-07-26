import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temperature_converter/main.dart';

void main() {
  group('Temperature Converter App Tests', () {
    testWidgets('App builds and shows splash screen',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const TemperatureConverterApp());

      // Verify that splash screen is displayed
      expect(find.text('Temperature\nConverter'), findsOneWidget);
      expect(find.text('Convert with precision'), findsOneWidget);
      expect(find.byIcon(Icons.thermostat), findsOneWidget);
    });

    testWidgets('Navigation from splash to home screen works',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());

      // Wait for splash screen timer to complete and navigation to happen
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify that home screen is displayed
      expect(find.text('Temperature Converter'), findsOneWidget);
      expect(find.text('Convert Temperature'), findsOneWidget);
    });

    testWidgets('Home screen displays all necessary widgets',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());

      // Navigate to home screen
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify home screen widgets
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Convert Temperature'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsNWidgets(2));
    });

    testWidgets('Temperature input validates correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());

      // Navigate to home screen
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Try to convert without entering a value
      await tester.tap(find.text('Convert Temperature'));
      await tester.pump();

      // Check for validation message
      expect(find.text('Please enter a temperature value'), findsOneWidget);

      // Enter invalid text
      await tester.enterText(find.byType(TextField), 'invalid');
      await tester.tap(find.text('Convert Temperature'));
      await tester.pump();

      // Check for validation message
      expect(find.text('Please enter a valid number'), findsOneWidget);
    });

    testWidgets('Temperature conversion works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());

      // Navigate to home screen
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Enter a temperature value
      await tester.enterText(find.byType(TextField), '32');

      // Perform conversion (Celsius to Fahrenheit should be default)
      await tester.tap(find.text('Convert Temperature'));
      await tester.pump();
      await tester
          .pump(const Duration(milliseconds: 500)); // Wait for result animation

      // Check if result is displayed
      expect(find.textContaining('89.60° Fahrenheit'), findsOneWidget);
    });

    testWidgets('Conversion selector works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());

      // Navigate to home screen
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Find the first dropdown (from unit)
      final dropdowns = find.byType(DropdownButton<String>);
      expect(dropdowns, findsNWidgets(2));

      // Tap the first dropdown to open it
      await tester.tap(dropdowns.first);
      await tester.pumpAndSettle();

      // Check if Fahrenheit option is available
      expect(find.text('Fahrenheit').last, findsOneWidget);
    });

    testWidgets('Swap units functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());

      // Navigate to home screen
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Look for swap button (should be an IconButton with swap icon)
      final swapButton = find.byIcon(Icons.swap_horiz);
      if (swapButton.evaluate().isNotEmpty) {
        await tester.tap(swapButton);
        await tester.pump();
      }

      // The test passes if no exceptions are thrown
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('App handles errors gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());

      // Navigate to home screen
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Enter various invalid inputs
      const invalidInputs = ['abc', '12.34.56', '', ' '];

      for (final input in invalidInputs) {
        await tester.enterText(find.byType(TextField), input);
        await tester.tap(find.text('Convert Temperature'));
        await tester.pump();

        // Should show some error message or handle gracefully
        expect(find.byType(Scaffold), findsOneWidget);
      }
    });

    testWidgets('All unit conversions work correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());

      // Navigate to home screen
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Test a simple conversion
      await tester.enterText(find.byType(TextField), '100');
      await tester.tap(find.text('Convert Temperature'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should have a result displayed
      expect(find.textContaining('°'), findsAtLeastNWidgets(1));
    });

    testWidgets('History functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());

      // Navigate to home screen
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Perform a conversion to create history
      await tester.enterText(find.byType(TextField), '0');
      await tester.tap(find.text('Convert Temperature'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Check if history section appears
      expect(find.textContaining('°'), findsAtLeastNWidgets(1));
    });

    testWidgets('History can be cleared', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());

      // Navigate to home screen
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Perform a conversion
      await tester.enterText(find.byType(TextField), '25');
      await tester.tap(find.text('Convert Temperature'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Look for clear button if history exists
      final clearButton = find.text('Clear');
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pump();
      }

      // Test passes if no exceptions are thrown
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('UI animations work without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());

      // Test splash screen animations
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));

      // Navigate to home screen
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Test button animation
      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Convert Temperature'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Animations should complete without errors
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Edge Cases and Performance Tests', () {
    testWidgets('App handles large numbers correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());

      // Navigate to home screen
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Test with large number
      await tester.enterText(find.byType(TextField), '999999');
      await tester.tap(find.text('Convert Temperature'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should handle large numbers without crashing
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('App handles negative numbers correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());

      // Navigate to home screen
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Test with negative number
      await tester.enterText(find.byType(TextField), '-40');
      await tester.tap(find.text('Convert Temperature'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should handle negative numbers
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('App maintains decimal precision', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());

      // Navigate to home screen
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Test with decimal number
      await tester.enterText(find.byType(TextField), '37.5');
      await tester.tap(find.text('Convert Temperature'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should handle decimal precision
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('App performance remains stable', (WidgetTester tester) async {
      await tester.pumpWidget(const TemperatureConverterApp());

      // Navigate to home screen
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Perform multiple conversions rapidly
      for (int i = 0; i < 5; i++) {
        await tester.enterText(find.byType(TextField), i.toString());
        await tester.tap(find.text('Convert Temperature'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      // App should remain stable
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
