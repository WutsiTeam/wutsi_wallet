import 'dart:async';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sdui/sdui.dart';
import 'package:wutsi_wallet/src/access_token.dart';
import 'package:wutsi_wallet/src/device.dart';
import 'package:wutsi_wallet/src/http.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

String onboardBaseUrl = 'https://wutsi-onboard-bff-test.herokuapp.com';
String loginBaseUrl = 'https://wutsi-login-bff-test.herokuapp.com';
String shellBaseUrl = 'https://wutsi-shell-bff-test.herokuapp.com';

Device device = Device('');
AccessToken accessToken = AccessToken(null, {});
Logger logger = LoggerFactory.create('main');

void main() async {
  runZonedGuarded<Future<void>>(() async {
    _launch();
  }, (error, stack) => {
    if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
      FirebaseCrashlytics.instance.recordError(error, stack)
    }
  });
}

void _launch() async {
  WidgetsFlutterBinding.ensureInitialized();

  device = await Device.get();
  accessToken = await AccessToken.get();
  logger.i('device-id=${device.id} access-token=${accessToken.value}');

  _initHttp();
  _initCrashlytics();

  runApp(const WutsiApp());
}

void _initHttp() {
  logger.i('Initializing HTTP');
  Http.getInstance().interceptors = [
    HttpJsonInterceptor(),
    HttpAuthorizationInterceptor(accessToken),
    HttpTracingInterceptor('wutsi-wallet', device.id, 1),
    HttpInternationalizationInterceptor(),
  ];
}

void _initCrashlytics() async {
  if (kDebugMode) {
    logger.i('Running in debug mode. Crashlytics disabled');

    // Force disable Crashlytics collection while doing every day development.
    // Temporarily toggle this to true if you want to test crash reporting in your app.
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(false);
  } else {
    logger.i('Initializing Crashlytics');

    await Firebase.initializeApp();

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    FirebaseCrashlytics.instance.setCustomKey("device_id", device.id);

    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);
  }
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
      navigatorObservers: [routeObserver],
      routes: {
        '/': (context) =>
            DynamicRoute(provider: HttpRouteContentProvider(shellBaseUrl)),
        '/login': (context) =>
            DynamicRoute(provider: LoginContentProvider(context)),
        '/onboard': (context) =>
            DynamicRoute(provider: HttpRouteContentProvider(onboardBaseUrl)),
      },
    );
  }

  String _initialRoute() {
    String url = '/login';

    if (!accessToken.exists()) {
      url = '/onboard';
    } else if (accessToken.expired()) {
      logger.i('access_token has expired');
      url = '/login';
    }
    logger.i('initial-route=$url');
    return url;
  }
}

class LoginContentProvider implements RouteContentProvider {
  final BuildContext context;

  const LoginContentProvider(this.context);

  @override
  Future<String> getContent() async =>
      Http.getInstance().post(await _url(), null);

  Future<String> _url() async {
    String url = onboardBaseUrl;
    Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      logger.i('Login with arguments: $args');

      var query = '';
      var phone = args['phone']?.toString().trim();
      if (phone != null && phone.isNotEmpty) {
        query += '&phone=$phone&';

        var title = args['title'];
        if (title != null && title.isNotEmpty) {
          query += '&title=$title';
        }

        var subTitle = args['sub-title'];
        if (subTitle != null && subTitle.isNotEmpty) {
          query += '&sub-title=$subTitle';
        }

        url = loginBaseUrl + "?$query";
      }
    } else {
      if (accessToken.exists()) {
        return loginBaseUrl + "?phone=${accessToken.phoneNumber()}";
      }
    }

    logger.i('login-url=$url');
    return url;
  }
}
