import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oneplus_ios27_theme/main.dart';

void main() {
  testWidgets('Launcher app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: OnePlusIOS27LauncherApp(),
      ),
    );

    expect(find.byType(LauncherHomeScreen), findsOneWidget);
  });
}
