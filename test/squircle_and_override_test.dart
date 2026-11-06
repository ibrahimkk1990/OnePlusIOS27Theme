import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oneplus_ios27_theme/widgets/squircle_icon.dart';
import 'package:oneplus_ios27_theme/services/icon_override_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Apple Squircle Superellipse Tests', () {
    test('SuperellipseClipper generates closed path with correct bounds', () {
      const clipper = SuperellipseClipper(n: 4.4, samples: 100);
      const size = Size(60, 60);
      final path = clipper.getClip(size);

      expect(path, isNotNull);
      final bounds = path.getBounds();
      // Bound should be approximately within (0,0, 60, 60)
      expect(bounds.width, closeTo(60.0, 1.0));
      expect(bounds.height, closeTo(60.0, 1.0));
    });

    testWidgets('SquircleIcon renders with ClipPath and fallback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SquircleIcon(
              size: 60.0,
            ),
          ),
        ),
      );

      expect(find.byType(SquircleIcon), findsOneWidget);
      expect(find.byType(ClipPath), findsOneWidget);
    });
  });

  group('Icon Override System Tests', () {
    test('IconOverrideService stores and retrieves custom mappings', () async {
      final service = IconOverrideService();

      // Should contain default Chrome -> Safari mapping
      final initial = await service.loadMappings();
      expect(initial['com.android.chrome'], equals('assets/icons/safari.png'));

      // Add a custom override
      await service.setOverride('com.custom.browser', 'assets/icons/safari.png');
      final fetched = await service.getOverride('com.custom.browser');
      expect(fetched, equals('assets/icons/safari.png'));

      // Remove custom override
      await service.removeOverride('com.custom.browser');
      final afterRemove = await service.getOverride('com.custom.browser');
      expect(afterRemove, isNull);
    });
  });
}
