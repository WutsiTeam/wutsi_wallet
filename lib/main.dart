import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wutsi_wallet/src/device.dart';
import 'package:wutsi_wallet/src/http.dart';

String onboardBaseUrl = 'https://wutsi-onboard-bff-test.herokuapp.com';
String appBaseUrl = 'https://wutsi-cash-bff-test.herokuapp.com';
bool? onboarded;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Http.getInstance().interceptors = [
    HttpJsonInterceptor(),
    HttpInternationalizationInterceptor(),
    HttpTracingInterceptor('wutsi-wallet', await Device().id())
  ];

  onboarded = (await SharedPreferences.getInstance())
      .getBool(HttpOnboardingInterceptor.headerOnboarded);

  runApp(const WutsiApp());
}

class WutsiApp extends StatelessWidget {
  const WutsiApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wutsi Wallet',
      debugShowCheckedModeBanner: false,
      initialRoute: onboarded == true ? '/' : '/onboard',
      routes: {
        '/': (context) => const HomeScreen(),
        '/onboard': (context) => DynamicRoute(
            provider: HttpRouteContentProvider('$onboardBaseUrl/screens/home')),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const Center(child: Text('HOME'));
}
