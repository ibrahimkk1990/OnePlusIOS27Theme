import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oneplus_ios27_theme/main.dart';
import 'package:oneplus_ios27_theme/screens/launcher_home_screen.dart';

void main() {
  testWidgets('Launcher home screen renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: OnePlusIOS27ThemeApp(),
      ),
    );

    expect(find.byType(LauncherHomeScreen), findsOneWidget);
  });
}
