import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sdui/sdui.dart';
import 'package:wutsi_wallet/src/access_token.dart';
import 'package:wutsi_wallet/src/analytics.dart';
import 'package:wutsi_wallet/src/camera.dart';
import 'package:wutsi_wallet/src/contact.dart';
import 'package:wutsi_wallet/src/crashlytics.dart';
import 'package:wutsi_wallet/src/device.dart';
import 'package:wutsi_wallet/src/http.dart';
import 'package:wutsi_wallet/src/language.dart';
import 'package:wutsi_wallet/src/loading.dart';

const String onboardBaseUrl = 'https://wutsi-onboard-bff-test.herokuapp.com';
const String loginBaseUrl = 'https://wutsi-login-bff-test.herokuapp.com';
const String shellBaseUrl = 'https://wutsi-shell-bff-test.herokuapp.com';
const String cashBaseUrl = 'https://wutsi-cash-bff-test.herokuapp.com';

final Logger logger = LoggerFactory.create('main');
Device device = Device('');
AccessToken accessToken = AccessToken(null, {});
Language language = Language('en');

void main() async {
  runZonedGuarded<Future<void>>(() async {
    _launch();
  },
      (error, stack) => {
            if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled)
              {FirebaseCrashlytics.instance.recordError(error, stack)}
          });
}

void _launch() async {
  WidgetsFlutterBinding.ensureInitialized();

  device = await Device.get();
  accessToken = await AccessToken.get();
  language = await Language.get();
  logger.i(
      'device-id=${device.id} access-token=${accessToken.value} language=${language.value}');

  logger.i('Initializing HTTP');
  initHttp('wutsi-wallet', accessToken, device, language);

  logger.i('Initializing Crashlytics');
  initCrashlytics(device);

  logger.i('Initializing Analytics');
  initAnalytics(accessToken, device);

  logger.i('Initializing Loading State');
  initLoadingState();

  logger.i('Initializing Contacts');
  initContacts('$shellBaseUrl/commands/sync-contacts');

  logger.i('Initializing the camera');
  int count = await initCamera();
  logger.i(
      '$count Cameras: ' + sduiCameras.map((e) => e.lensDirection).toString());

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
      navigatorObservers: [sduiRouteObserver, analyticsObserver],
      routes: {
        '/': (context) => const DynamicRoute(
            provider: HttpRouteContentProvider("$cashBaseUrl/send")),
        '/login': (context) =>
            DynamicRoute(provider: LoginContentProvider(context)),
        '/onboard': (context) => const DynamicRoute(
            provider: HttpRouteContentProvider(onboardBaseUrl)),
      },
    );
  }

  String _initialRoute() => !accessToken.exists() ? '/onboard' : '/login';
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
