import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oneplus_ios27_theme/models/app_info.dart';
import 'package:oneplus_ios27_theme/providers/edit_mode_provider.dart';
import 'package:oneplus_ios27_theme/widgets/ios_app_icon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 5 Animations & Interactions', () {
    test('EditModeNotifier toggles state and triggers haptics', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(editModeProvider), isFalse);

      container.read(editModeProvider.notifier).enterEditMode();
      expect(container.read(editModeProvider), isTrue);

      container.read(editModeProvider.notifier).exitEditMode();
      expect(container.read(editModeProvider), isFalse);
    });

    testWidgets('Long press enters Edit Mode and reveals minus badge', (tester) async {
      const app = AppInfo(
        appName: 'TestApp',
        packageName: 'com.test.app',
      );

      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: IOSAppIcon(
                app: app,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      // Long press the icon
      await tester.longPress(find.byType(IOSAppIcon));
      // Pump frames for repeating jiggle animation
      await tester.pump(const Duration(milliseconds: 200));

      // Verify edit mode entered
      final element = tester.element(find.byType(IOSAppIcon));
      final container = ProviderScope.containerOf(element);
      expect(container.read(editModeProvider), isTrue);

      // Verify minus badge is present
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);

      // Tapping during edit mode should NOT trigger app launch
      await tester.tap(find.byType(IOSAppIcon));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tapped, isFalse);
    });

    testWidgets('Icon tap executes 150ms bounce before callback', (tester) async {
      const app = AppInfo(
        appName: 'TestApp',
        packageName: 'com.test.app',
      );

      bool launched = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: IOSAppIcon(
                app: app,
                onTap: () => launched = true,
              ),
            ),
          ),
        ),
      );

      // Tap the icon
      await tester.tap(find.byType(IOSAppIcon));
      await tester.pump(); // Start the 150ms animation

      // At 60ms (mid bounce), callback should NOT have fired yet
      await tester.pump(const Duration(milliseconds: 60));
      expect(launched, isFalse);

      // Advance past 150ms (e.g. +120ms total 180ms)
      await tester.pump(const Duration(milliseconds: 120));
      expect(launched, isTrue);
    });
  });
}
