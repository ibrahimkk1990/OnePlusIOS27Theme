import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oneplus_ios27_theme/widgets/small_ios_widget.dart';
import 'package:oneplus_ios27_theme/widgets/medium_ios_widget.dart';
import 'package:oneplus_ios27_theme/widgets/sample_widgets/weather_widget.dart';
import 'package:oneplus_ios27_theme/widgets/sample_widgets/battery_widget.dart';

void main() {
  group('Phase 6: Simulated iOS Widgets Tests', () {
    testWidgets('SmallIOSWidget renders with squircle container', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SmallIOSWidget(
                child: Text('Small Widget Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SmallIOSWidget), findsOneWidget);
      expect(find.text('Small Widget Content'), findsOneWidget);
    });

    testWidgets('MediumIOSWidget renders with 4-column span', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MediumIOSWidget(
                child: Text('Medium Widget Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MediumIOSWidget), findsOneWidget);
      expect(find.text('Medium Widget Content'), findsOneWidget);
    });

    testWidgets('WeatherWidget renders city, temperature, and icon', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WeatherWidget(
                city: 'Cupertino',
                temperature: '72°',
                condition: 'Mostly Sunny',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(WeatherWidget), findsOneWidget);
      expect(find.text('Cupertino'), findsOneWidget);
      expect(find.text('72°'), findsOneWidget);
      expect(find.text('Mostly Sunny'), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
    });

    testWidgets('BatteryWidget renders 4 device rings and percentages', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BatteryWidget(),
            ),
          ),
        ),
      );

      expect(find.byType(BatteryWidget), findsOneWidget);
      expect(find.text('Batteries'), findsOneWidget);
      expect(find.text('88%'), findsOneWidget);
      expect(find.text('OnePlus 12'), findsOneWidget);
      expect(find.text('Buds Pro'), findsOneWidget);
    });
  });
}
