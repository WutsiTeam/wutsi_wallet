import 'package:integration_test/integration_test.dart';
import 'package:wutsi_wallet/main.dart' as app;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


Future<void> restoreFlutterError(Future<void> Function() call) async {
  final originalOnError = FlutterError.onError!;
  await call();
  final overriddenOnError = FlutterError.onError!;

  // restore FlutterError.onError
  FlutterError.onError = (FlutterErrorDetails details) {
    if (overriddenOnError != originalOnError) overriddenOnError(details);
    originalOnError(details);
  };
}

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  group(('WU-105'), () {

    testWidgets('normal user account update WU-105',
            (WidgetTester tester) async {
//setup
            app.main();

          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds: 5));

          await tester.pumpAndSettle();
          final Finder phonefield = find
              .byType(TextField)
              .first;
          final Finder nextbutton = find.text('Next', findRichText: true);

//do
          await Future.delayed(const Duration(seconds: 1));
          await tester.enterText(phonefield, "693842356");
          await Future.delayed(const Duration(seconds: 1));
          await tester.tap(nextbutton);
          await Future.delayed(const Duration(seconds: 5));
          await tester.pumpAndSettle();
          final Finder otpField = find
              .byType(TextField)
              .first;
          await tester.enterText(otpField, "612321");
          await tester.tap(find.text('Next', findRichText: true));
          await tester.pumpAndSettle();
          for (int i = 1; i <= 6; i++) {
            await tester.tap(find.text("$i", findRichText: true));
          }
          await Future.delayed(const Duration(seconds: 5));
          await tester.pumpAndSettle();

          final Finder paramIcon = find.descendant(
              of: find.byType(NavigationToolbar), matching: find.byType(Icon)
          );
          final Finder paramIcon1 = find
              .byType(Icon)
              .first;

          await tester.tap(paramIcon);
          await tester.pumpAndSettle();
//test
          await Future.delayed(const Duration(seconds: 3));
          await tester.pumpAndSettle();

          expect(find.text('Profile'), findsOneWidget);
        });
  });
}
