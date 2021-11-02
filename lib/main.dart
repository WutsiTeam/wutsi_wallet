import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wutsi_wallet/src/device.dart';
import 'package:wutsi_wallet/src/http.dart';

bool? onboarded;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Http.getInstance().interceptors = [
    HttpJsonInterceptor(),
    HttpInternationalizationInterceptor(),
    HttpTracingInterceptor("demo", await Device().id())
  ];

  onboarded = (await SharedPreferences.getInstance())
      .getBool(HttpOnboardingInterceptor.headerOnboarded);

  runApp(const WutsiApp());
}

class WutsiApp extends StatelessWidget {
  final String baseUrl;

  const WutsiApp(
      {this.baseUrl = 'https://wutsi-onboard-bff-test.herokuapp.com', Key? key})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wutsi Wallet',
      debugShowCheckedModeBanner: false,

      // initialRoute: onboarded == true ? "/" : "/onboard",
      initialRoute: "/",
      routes: {
        '/': (context) => const HomeScreen(),
        '/onboard': (context) => DynamicRoute(
            provider:
                HttpRouteContentProvider('$baseUrl/app/onboard/screens/home')),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('HOME'),
        ),
      );
}
