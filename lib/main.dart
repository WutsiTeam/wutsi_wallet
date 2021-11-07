import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import 'package:sdui/sdui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wutsi_wallet/src/device.dart';
import 'package:wutsi_wallet/src/http.dart';

String onboardBaseUrl = 'https://wutsi-onboard-bff-test.herokuapp.com';
String loginBaseUrl = 'https://wutsi-login-bff-test.herokuapp.com';
String cashBaseUrl = 'https://wutsi-cash-bff-test.herokuapp.com';

bool? onboarded;
String? accessToken;
Logger logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Http.getInstance().interceptors = [
    HttpJsonInterceptor(),
    HttpInternationalizationInterceptor(),
    HttpTracingInterceptor('wutsi-wallet', await Device().id()),
    HttpAuthorizationInterceptor()
  ];

  onboarded = (await SharedPreferences.getInstance())
      .getBool(HttpOnboardingInterceptor.headerOnboarded);
  accessToken = (await SharedPreferences.getInstance())
      .getString(HttpAuthorizationInterceptor.headerAccessToken);
  logger.i('STARTING APP. onboarded=$onboarded - accessToken=$accessToken');

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
      initialRoute: _initialRoute(),
      routes: {
        '/': (context) => DynamicRoute(
            provider: HttpRouteContentProvider('$cashBaseUrl/screens/home')),
        '/login': (context) =>
            DynamicRoute(provider: LoginContentProvider(context)),
        '/onboard': (context) =>
            DynamicRoute(provider: HttpRouteContentProvider(onboardBaseUrl)),
      },
    );
  }

  String _initialRoute() {
    if (onboarded != null) {
      return '/onboard';
    } else {
      return accessToken == null ? '/login' : '/';
    }
  }
}

class LoginContentProvider implements RouteContentProvider {
  final BuildContext context;

  const LoginContentProvider(this.context);

  @override
  Future<String> getContent() async => Http.getInstance().post(_url(), null);

  String _url() {
    Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      logger.i('Login with arguments: $args');
      var phone = args['phone'];
      var title = args['title'];
      var subTitle = args['sub-title'];
      var query = '';
      if (phone != null) {
        query += '&phone=$phone&';
      }
      if (title != null) {
        query += '&title=$title';
      }
      if (subTitle != null) {
        query += '&sub-title=$subTitle';
      }
      if (query.isNotEmpty) {
        return loginBaseUrl + "?$query";
      }
    } else if (accessToken != null) {
      Map<String, dynamic> token = JwtDecoder.decode(accessToken!);
      logger.i('Login with JWT: $token');
      String? phone = token['phone_number'];
      if (phone == null) {
        return loginBaseUrl + "?phone=$phone";
      }
    }
    return onboardBaseUrl;
  }
}
