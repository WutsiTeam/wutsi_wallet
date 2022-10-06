import 'package:integration_test/integration_test.dart';
import 'package:wutsi_wallet/main.dart' as app;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

//Method to deal with FlutterError overridding
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
  if (binding is LiveTestWidgetsFlutterBinding) {
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;}

  group (('WU-84'),(){
  testWidgets('User enter a valid phone Number WU-84 E1', (tester) async {
    app.main();
     await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds : 5  ));
    var phonefield = find.byType(TextField).first;
    var nextbutton = find.text('Next', findRichText: true);
    //do
    // await tester.tap(phonefield);
    await Future.delayed(const Duration(seconds : 1));
    await tester.enterText(phonefield, "690904040");
    await Future.delayed(const Duration(seconds : 1));
    await tester.tap(nextbutton);
    await Future.delayed(const Duration(seconds : 5));
    await tester.pumpAndSettle();
    //test
      expect (find.text('Verification Code'), findsOneWidget);
  });
  testWidgets('User enter a valid phone Number WU-84 E2', (tester) async {
      app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds : 5  ));
    var phonefield = find.byType(TextField).first;
    var nextbutton = find.text('Next', findRichText: true);
    //do
    // await tester.tap(phonefield);
    await Future.delayed(const Duration(seconds : 1));
    await tester.enterText(phonefield, "677404040");
    await Future.delayed(const Duration(seconds : 1));
    await tester.tap(nextbutton);
    await Future.delayed(const Duration(seconds : 5));
    await tester.pumpAndSettle();
    //test
    expect (find.text('Verification Code'), findsOneWidget);
  });
  });
  group (('WU-109'),(){
  testWidgets('normal user city exist in drop-down', (tester) async {
    // await restoreFlutterError(() async {app.main();
    app.main();
     await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds : 5  ));
    var phonefield = find.byType(TextField).first;
    var nextbutton = find.text('Next', findRichText: true);
    //do
    // await tester.tap(phonefield);
    await Future.delayed(const Duration(seconds : 1));
    await tester.enterText(phonefield, "690904938");
    await Future.delayed(const Duration(seconds : 1));
    await tester.tap(nextbutton);
    await Future.delayed(const Duration(seconds : 5));
    await tester.pumpAndSettle();
    var  otpField = find.byType(TextField).first;
    await tester.enterText(otpField, "000000");
    await tester.tap(find.text('Next', findRichText: true));
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds : 3));
    var  nameField = find.byType(TextField).first;
    await tester.enterText(nameField, "John Doe");
    await tester.tap(find.text('Next', findRichText: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Icon).at(1));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, "douala");
    await Future.delayed(const Duration(seconds : 3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Douala, Cameroon'));
    await Future.delayed(const Duration(seconds : 5));
    await tester.pumpAndSettle();
    var  submit = find.text('Submit', findRichText: true);
    await Future.delayed(const Duration(seconds : 5));



    //test
      expect (find.text('Create your PIN', findRichText: true), findsWidgets);
  });
  });
  group (('WU-114'),(){
      testWidgets('The user enter an Incorrect OTP',
              (WidgetTester tester) async {
                  app.main();
                await tester.pumpAndSettle();
                await Future.delayed(const Duration(seconds : 5  ));
                var phonefield = find.byType(TextField).first;
                var nextbutton = find.text('Next', findRichText: true);
                //do
                // await tester.tap(phonefield);
                await Future.delayed(const Duration(seconds : 1));
                await tester.enterText(phonefield, "677404040");
                await Future.delayed(const Duration(seconds : 1));
                await tester.tap(nextbutton);
                await Future.delayed(const Duration(seconds : 5));
                await tester.pumpAndSettle();
                await Future.delayed(const Duration(seconds : 5));
                await tester.pumpAndSettle();
                final Finder otpField = find.byType(TextField).first;
                await tester.enterText(otpField, "000000");
                await tester.tap(find.text('Next', findRichText: true));
                await Future.delayed(const Duration(seconds : 10));
                // await tester.pumpAndSettle();
                //test
                expect (find.text('The verification code is invalid!'), findsOneWidget);

          });
    });
  group (('WU-113'),(){
      testWidgets('The user enter a correct OTP and an incorrect PIN',
              (WidgetTester tester) async {
            //setup
              app.main();
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 5  ));
            var phonefield = find.byType(TextField).first;
            var nextbutton = find.text('Next', findRichText: true);
            //do
            // await tester.tap(phonefield);
            await Future.delayed(const Duration(seconds : 1));
            await tester.enterText(phonefield, "696074190");
            await Future.delayed(const Duration(seconds : 1));
            await tester.tap(nextbutton);
            await Future.delayed(const Duration(seconds : 5));
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 5));
            await tester.pumpAndSettle();
            final Finder otpField = find.byType(TextField).first;
            await tester.enterText(otpField, "000000");
            await tester.tap(find.text('Next', findRichText: true));
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 3));
            final Finder oneField = find.text('1', findRichText: true);
            final Finder threeField = find.text('3', findRichText: true);
            for (int j = 1;j <= 3;j++){
              await tester.pumpAndSettle();
              // await tester.pump(const Duration(milliseconds: 1000));
              await tester.tap(oneField);
              await tester.pumpAndSettle();
              // await tester.pump(const Duration(milliseconds: 1000));
              await tester.tap(threeField);
            }
            await Future.delayed(const Duration(seconds : 3));

            //test
            expect (find.text('Sorry! The PIN is not valid.'), findsOneWidget);
            // expect (find.text('Error'), findsOneWidget);
              });
    });
  group (('WU-110'),(){
      testWidgets('normal user city do not exist in drop-down',
              (WidgetTester tester) async {
            //setup
              app.main();
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 5  ));
            var phonefield = find.byType(TextField).first;
            var nextbutton = find.text('Next', findRichText: true);
            //do
            // await tester.tap(phonefield);
            await Future.delayed(const Duration(seconds : 1));
            await tester.enterText(phonefield, "690904938");
            await Future.delayed(const Duration(seconds : 1));
            await tester.tap(nextbutton);
            await tester.pumpAndSettle();
            Finder otpField = find.byType(TextField).first;
            await tester.enterText(otpField, "000000");
            await tester.tap(find.text('Next', findRichText: true));
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 3));
            Finder nameField = find.byType(TextField).first;
            await tester.enterText(nameField, "John Doe");
            await tester.tap(find.text('Next', findRichText: true));
            await tester.pumpAndSettle();
            await tester.tap(find.byType(Icon).at(1));
            await tester.pumpAndSettle();
            final Finder whatWeVerify = find.descendant(
                of: find.byType(DropdownMenuItem), matching: find.text('Cocody'));
            await tester.enterText(find.byType(TextField).first, "Cocody");
            await Future.delayed(const Duration(seconds : 2));
            await tester.pumpAndSettle();

            //test

              expect (whatWeVerify, findsNothing);



            // expect (find.text('Error'), findsOneWidget);
          });
    });
  group (('WU-92'),(){
      testWidgets('User enter a name shorter than 50 characters',
              (WidgetTester tester) async {
            //setup
              app.main();
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 5  ));
            var phonefield = find.byType(TextField).first;
            var nextbutton = find.text('Next', findRichText: true);
            //do
            // await tester.tap(phonefield);
            await Future.delayed(const Duration(seconds : 1));
            await tester.enterText(phonefield, "690904938");
            await Future.delayed(const Duration(seconds : 1));
            await tester.tap(nextbutton);
            await Future.delayed(const Duration(seconds : 5));
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 5));
            await tester.pumpAndSettle();
            final Finder otpField = find.byType(TextField).first;
            await tester.enterText(otpField, "000000");
            await tester.tap(find.text('Next', findRichText: true));
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 3));
            final Finder nameField = find.byType(TextField).first;
            final Finder oneField2 = find.text('0', findRichText: true);
            await tester.enterText(nameField, "John Doe");
            await tester.tap(find.text('Next', findRichText: true));
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 3));
            await tester.pumpAndSettle();
            //test
            expect (find.text('Select your city'), findsOneWidget);
            // expect (find.text('Error'), findsOneWidget);
          });
    });
  group (('WU-93'),(){
    // testWidgets('no sense', (tester) async { await restoreFlutterError(() async {});});
    testWidgets('User tries to enter a name longer than 50 characters',
            (WidgetTester tester) async {
          //setup
            app.main();
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 5  ));
          var phonefield = find.byType(TextField).first;
          var nextbutton = find.text('Next', findRichText: true);
          //do
          // await tester.tap(phonefield);
          await Future.delayed(const Duration(seconds : 1));
          await tester.enterText(phonefield, "690904938");
          await Future.delayed(const Duration(seconds : 1));
          await tester.tap(nextbutton);
          await Future.delayed(const Duration(seconds : 5));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 5));
          await tester.pumpAndSettle();
          final Finder otpField = find.byType(TextField).first;
          await tester.enterText(otpField, "000000");
          await tester.tap(find.text('Next', findRichText: true));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 3));
          final Finder nameField = find.byType(TextField).first;
          final Finder oneField2 = find.text('0', findRichText: true);
          await tester.enterText(nameField, "John doe AAAAAAA AAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA BBBB");
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 3));
          //test
          expect (find.text('John doe AAAAAAA AAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAA'), findsOneWidget);
              // expect (find.text('Error'), findsOneWidget);
        });
  });
  group (('WU-94'),(){
    testWidgets('The user does not fill the Full Name field',
            (WidgetTester tester) async {
          //setup
            app.main();
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 5  ));
          var phonefield = find.byType(TextField).first;
          var nextbutton = find.text('Next', findRichText: true);
          //do
          // await tester.tap(phonefield);
          await Future.delayed(const Duration(seconds : 1));
          await tester.enterText(phonefield, "690904938");
          await Future.delayed(const Duration(seconds : 1));
          await tester.tap(nextbutton);
          await Future.delayed(const Duration(seconds : 5));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 5));
          await tester.pumpAndSettle();
          final Finder otpField = find.byType(TextField).first;
          await tester.enterText(otpField, "000000");
          await tester.tap(find.text('Next', findRichText: true));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 3));
          await tester.tap(find.text('Next', findRichText: true));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 3));
          //test
          expect (find.text('This field must have at least 5 characters'), findsOneWidget);
          // expect (find.text('Error'), findsOneWidget);
        });
  });
  group (('WU-111'),(){
      testWidgets('User did not add his city',
              (WidgetTester tester) async {
            //setup
            app.main();

            await Future.delayed(const Duration(seconds : 5  ));
            var phonefield = find.byType(TextField).first;
            var nextbutton = find.text('Next', findRichText: true);
            //do
            // await tester.tap(phonefield);
            await Future.delayed(const Duration(seconds : 1));
            await tester.enterText(phonefield, "690904938");
            await Future.delayed(const Duration(seconds : 1));
            await tester.tap(nextbutton);
            await tester.pumpAndSettle();
            final Finder otpField = find.byType(TextField).first;
            await tester.enterText(otpField, "000000");
            await tester.tap(find.text('Next', findRichText: true));
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 3));
            final Finder nameField = find.byType(TextField).first;
            await tester.enterText(nameField, "John Doe");
            await tester.tap(find.text('Next', findRichText: true));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Skip'));
           await Future.delayed(const Duration(seconds : 5));


            await Future.delayed(const Duration(seconds : 5));


            //test
            expect (find.text('Create your PIN', findRichText: true), findsWidgets);

            // expect (find.text('Error'), findsOneWidget);
          });
    });
  group (('WU-91'),(){
      testWidgets('The user add his valid phone number and enter a wrong validation code E1',
              (WidgetTester tester) async {
            //setup
              app.main();
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 5  ));
            var phonefield = find.byType(TextField).first;
            var nextbutton = find.text('Next', findRichText: true);
            //do
            await Future.delayed(const Duration(seconds : 1));
            await tester.enterText(phonefield, "677404040");
            await Future.delayed(const Duration(seconds : 1));
            await tester.tap(nextbutton);
            await Future.delayed(const Duration(seconds : 5));
            await tester.pumpAndSettle();
            final Finder otpField = find.byType(TextField).first;
            await tester.enterText(otpField, "0000");
            await tester.tap(find.text('Next', findRichText: true));
            await Future.delayed(const Duration(seconds : 5));
            //test
            expect (find.text('This field must have at least 6 characters'), findsOneWidget);
          });
      testWidgets('The user add his valid phone number and enter a wrong validation code E2',
              (WidgetTester tester) async {
            //setup
              app.main();
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 5  ));
            var phonefield = find.byType(TextField).first;
            var nextbutton = find.text('Next', findRichText: true);
            //do
            await Future.delayed(const Duration(seconds : 1));
            await tester.enterText(phonefield, "677404040");
            await Future.delayed(const Duration(seconds : 1));
            await tester.tap(nextbutton);
            await Future.delayed(const Duration(seconds : 5));
            await tester.pumpAndSettle();
            final Finder otpField = find.byType(TextField).first;
            await tester.enterText(otpField, "1");
            await tester.tap(find.text('Next', findRichText: true));
            await Future.delayed(const Duration(seconds : 5));
            //test
            expect (find.text('This field must have at least 6 characters'), findsOneWidget);
          });
      testWidgets('The user add his valid phone number and enter a wrong validation code E3',
              (WidgetTester tester) async {
            //setup
              app.main();
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 5  ));
            var phonefield = find.byType(TextField).first;
            var nextbutton = find.text('Next', findRichText: true);
            //do
            await Future.delayed(const Duration(seconds : 1));
            await tester.enterText(phonefield, "677404040");
            await Future.delayed(const Duration(seconds : 1));
            await tester.tap(nextbutton);
            await Future.delayed(const Duration(seconds : 5));
            await tester.pumpAndSettle();
            final Finder otpField = find.byType(TextField).first;
            await tester.enterText(otpField, "12");
            await tester.tap(find.text('Next', findRichText: true));
            await Future.delayed(const Duration(seconds : 5));
            //test
            expect (find.text('This field must have at least 6 characters'), findsOneWidget);
          });
      testWidgets('The user add his valid phone number and enter a wrong validation code E4',
              (WidgetTester tester) async {
            //setup
              app.main();
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 5  ));
            var phonefield = find.byType(TextField).first;
            var nextbutton = find.text('Next', findRichText: true);
            //do
            await Future.delayed(const Duration(seconds : 1));
            await tester.enterText(phonefield, "677404040");
            await Future.delayed(const Duration(seconds : 1));
            await tester.tap(nextbutton);
            await Future.delayed(const Duration(seconds : 5));
            await tester.pumpAndSettle();
            final Finder otpField = find.byType(TextField).first;
            await tester.enterText(otpField, "123");
            await tester.tap(find.text('Next', findRichText: true));
            await Future.delayed(const Duration(seconds : 5));
            //test
            expect (find.text('This field must have at least 6 characters'), findsOneWidget);
          });
      testWidgets('The user add his valid phone number and enter a wrong validation code E5',
              (WidgetTester tester) async {
            //setup
              app.main();
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 5  ));
            var phonefield = find.byType(TextField).first;
            var nextbutton = find.text('Next', findRichText: true);
            //do
            await Future.delayed(const Duration(seconds : 1));
            await tester.enterText(phonefield, "677404040");
            await Future.delayed(const Duration(seconds : 1));
            await tester.tap(nextbutton);
            await Future.delayed(const Duration(seconds : 5));
            await tester.pumpAndSettle();
            final Finder otpField = find.byType(TextField).first;
            await tester.enterText(otpField, "12345");
            await tester.tap(find.text('Next', findRichText: true));
            await Future.delayed(const Duration(seconds : 5));
            //test
            expect (find.text('This field must have at least 6 characters'), findsOneWidget);
          });
    });
  group (('WU-117'),(){
    testWidgets('The user first NIP does not match to the second NIP ',
            (WidgetTester tester) async {
          //setup
          app.main();

          await Future.delayed(const Duration(seconds : 5  ));
          var phonefield = find.byType(TextField).first;
          var nextbutton = find.text('Next', findRichText: true);
          //do
          // await tester.tap(phonefield);
          await Future.delayed(const Duration(seconds : 1));
          await tester.enterText(phonefield, "690904938");
          await Future.delayed(const Duration(seconds : 1));
          await tester.tap(nextbutton);
          await tester.pumpAndSettle();
          final Finder otpField = find.byType(TextField).first;
          await tester.enterText(otpField, "000000");
          await tester.tap(find.text('Next', findRichText: true));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 3));
          final Finder nameField = find.byType(TextField).first;
          await tester.enterText(nameField, "John Doe");
          await tester.tap(find.text('Next', findRichText: true));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Skip'));
          await Future.delayed(const Duration(seconds : 5));
          final Finder oneField = find.text('0', findRichText: true);
          final Finder oneField2 = find.byType(KeyedSubtree).at(16);
          for (int j = 1;j <= 3;j++){
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(milliseconds: 1000));
            await tester.tap(oneField);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(milliseconds: 1000));
            await tester.tap(oneField2);
          }
          await Future.delayed(const Duration(seconds : 3));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 3));
          for (int j = 1;j <= 3;j++){
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(milliseconds: 1000));
            await tester.tap(oneField);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(milliseconds: 1000));
            await tester.tap(find.text('1', findRichText: true));
          }
          await Future.delayed(const Duration(seconds : 3));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 3));
          //test
          expect (find.text('The PIN doesn\'t match.', findRichText: true), findsWidgets);

          // expect (find.text('Error'), findsOneWidget);
        });
  });
  group (('WU-118'),(){
    testWidgets('The user modify his NIP',
            (WidgetTester tester) async {
          //setup
          app.main();

          await Future.delayed(const Duration(seconds : 5  ));
          var phonefield = find.byType(TextField).first;
          var nextbutton = find.text('Next', findRichText: true);
          //do
          // await tester.tap(phonefield);
          await Future.delayed(const Duration(seconds : 1));
          await tester.enterText(phonefield, "690904938");
          await Future.delayed(const Duration(seconds : 1));
          await tester.tap(nextbutton);
          await tester.pumpAndSettle();
          final Finder otpField = find.byType(TextField).first;
          await tester.enterText(otpField, "000000");
          await tester.tap(find.text('Next', findRichText: true));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 3));
          final Finder nameField = find.byType(TextField).first;
          await tester.enterText(nameField, "John Doe");
          await tester.tap(find.text('Next', findRichText: true));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Skip'));
          await Future.delayed(const Duration(seconds : 5));
          final Finder oneField = find.text('0', findRichText: true);
          final Finder oneField2 = find.byType(KeyedSubtree).at(16);
          await tester.pumpAndSettle();
          for (int j = 1;j <= 3;j++){
            // await tester.pump(const Duration(milliseconds: 1000));
            await tester.tap(oneField);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(milliseconds: 1000));
            await tester.tap(find.text('1', findRichText: true));
          }
          await Future.delayed(const Duration(seconds : 3));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Change PIN.', findRichText: true));

          await Future.delayed(const Duration(seconds : 3));
          for (int j = 1;j <= 3;j++){
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(milliseconds: 1000));
            await tester.tap(oneField);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(milliseconds: 1000));
            await tester.tap(find.text('5', findRichText: true));
          }
          await Future.delayed(const Duration(seconds : 3));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 3));
          for (int j = 1;j <= 3;j++){
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(milliseconds: 1000));
            await tester.tap(oneField);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(milliseconds: 1000));
            await tester.tap(find.text('5', findRichText: true));
          }
          await Future.delayed(const Duration(seconds : 3));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 3));
          //test
          expect (find.text('Home', findRichText: true), findsWidgets);

          // expect (find.text('Error'), findsOneWidget);
        });
  });
  group (('WU-116'),(){
    testWidgets('The user enter the same valid 6 digit NIP twice',
            (WidgetTester tester) async {
          //setup
          app.main();

          await Future.delayed(const Duration(seconds : 5  ));
          var phonefield = find.byType(TextField).first;
          var nextbutton = find.text('Next', findRichText: true);
          //do
          // await tester.tap(phonefield);
          await Future.delayed(const Duration(seconds : 1));
          await tester.enterText(phonefield, "690904938");
          await Future.delayed(const Duration(seconds : 1));
          await tester.tap(nextbutton);
          await tester.pumpAndSettle();
          final Finder otpField = find.byType(TextField).first;
          await tester.enterText(otpField, "000000");
          await tester.tap(find.text('Next', findRichText: true));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 3));
          final Finder nameField = find.byType(TextField).first;
          await tester.enterText(nameField, "John Doe");
          await tester.tap(find.text('Next', findRichText: true));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Skip'));
          await Future.delayed(const Duration(seconds : 5));
          final Finder oneField = find.text('0', findRichText: true);
          final Finder oneField2 = find.byType(KeyedSubtree).at(16);
          for (int j = 1;j <= 3;j++){
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(milliseconds: 1000));
            await tester.tap(oneField);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(milliseconds: 1000));
            await tester.tap(oneField2);
          }
          await Future.delayed(const Duration(seconds : 3));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 3));
          for (int j = 1;j <= 3;j++){
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(milliseconds: 1000));
            await tester.tap(oneField);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(milliseconds: 1000));
            await tester.tap(oneField2);
          }
          await Future.delayed(const Duration(seconds : 3));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds : 3));
          //test
          expect (find.text('Home', findRichText: true), findsWidgets);

          // expect (find.text('Error'), findsOneWidget);
        });
  });

  group (('WU-112'),(){
      testWidgets('The user enter a correct OTP and an correct PIN',
              (WidgetTester tester) async {
            //setup
              app.main();
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 5  ));
            var phonefield = find.byType(TextField).first;
            var nextbutton = find.text('Next', findRichText: true);
            //do
            // await tester.tap(phonefield);
            await Future.delayed(const Duration(seconds : 1));
            await tester.enterText(phonefield, "696074190");
            await Future.delayed(const Duration(seconds : 1));
            await tester.tap(nextbutton);
            await Future.delayed(const Duration(seconds : 5));
            await tester.pumpAndSettle();
            final Finder otpField = find.byType(TextField).first;
            await tester.enterText(otpField, "000000");
            await tester.tap(find.text('Next', findRichText: true));
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds : 3));
            final Finder oneField = find.text('0', findRichText: true);
            final Finder oneField2 = find.byType(KeyedSubtree).at(16);
            for (int j = 1;j <= 3;j++){
              await tester.pumpAndSettle();
              // await tester.pump(const Duration(milliseconds: 1000));
              await tester.tap(oneField);
              await tester.pumpAndSettle();
              // await tester.pump(const Duration(milliseconds: 1000));
              await tester.tap(oneField2);
            }
            await Future.delayed(const Duration(seconds : 3));
            await tester.pumpAndSettle();
            //test
            expect (find.text('Home'), findsOneWidget);
            // expect (find.text('Error'), findsOneWidget);
          });
    });
}
