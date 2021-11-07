import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sdui/sdui.dart';
import 'package:wutsi_wallet/src/access_token.dart';
import 'package:wutsi_wallet/src/device.dart';
import 'package:wutsi_wallet/src/http.dart';

String onboardBaseUrl = 'https://wutsi-onboard-bff-test.herokuapp.com';
String loginBaseUrl = 'https://wutsi-login-bff-test.herokuapp.com';
// String loginBaseUrl = 'http://localhost:8080';
String cashBaseUrl = 'https://wutsi-cash-bff-test.herokuapp.com';

String? accessToken;
Logger logger = LoggerFactory.create('main');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Http.getInstance().interceptors = [
    HttpJsonInterceptor(),
    HttpInternationalizationInterceptor(),
    HttpTracingInterceptor('wutsi-wallet', await Device().id()),
    HttpAuthorizationInterceptor()
  ];

  accessToken = await AccessToken.get();

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
    String initialRoute = accessToken == null ? '/onboard' : '/';

    logger.i('access_token=$accessToken initial_route=$initialRoute');
    return initialRoute;
  }
}

class LoginContentProvider implements RouteContentProvider {
  final BuildContext context;

  const LoginContentProvider(this.context);

  @override
  Future<String> getContent() async =>
      Http.getInstance().post(await _url(), null);

  Future<String> _url() async {
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
    } else {
      Map<String, dynamic>? token = await AccessToken.decode();
      if (token != null) {
        logger.i('Login with JWT: $token');
        String? phone = token['phone_number'];
        if (phone == null) {
          return loginBaseUrl + "?phone=$phone";
        }
      }
    }
    return onboardBaseUrl;
  }
}
