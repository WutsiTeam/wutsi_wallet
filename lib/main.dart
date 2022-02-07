import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sdui/sdui.dart';
import 'package:wutsi_wallet/src/access_token.dart';
import 'package:wutsi_wallet/src/analytics.dart';
import 'package:wutsi_wallet/src/contact.dart';
import 'package:wutsi_wallet/src/crashlytics.dart';
import 'package:wutsi_wallet/src/device.dart';
import 'package:wutsi_wallet/src/environment.dart';
import 'package:wutsi_wallet/src/error.dart';
import 'package:wutsi_wallet/src/http.dart';
import 'package:wutsi_wallet/src/language.dart';
import 'package:wutsi_wallet/src/loading.dart';

const int tenantId = 1;

Environment environment = Environment(Environment.defaultEnvironment);

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

  environment = await Environment.get();
  device = await Device.get();
  accessToken = await AccessToken.get();
  language = await Language.get();
  logger.i(
      'device-id=${device.id} access-token=${accessToken.value} language=${language.value} environment=${environment.value}');

  logger.i('Initializing HTTP');
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  initHttp('wutsi-wallet', accessToken, device, language, tenantId, packageInfo,
      environment);

  logger.i('Initializing Crashlytics');
  initCrashlytics(device);

  logger.i('Initializing Analytics');
  initAnalytics(accessToken, device);

  logger.i('Initializing Loading State');
  initLoadingState();

  logger.i('Initializing Error page');
  initError(device);

  logger.i('Initializing Contacts');
  initContacts(environment.getShellUrl() + '/commands/sync-contacts');

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
      navigatorObservers: [sduiRouteObserver, analyticsObserver],
      initialRoute: '/',
      routes: {
        '/': (context) => DynamicRoute(provider: HomeContentProvider(context)),
        '/401': (context) =>
            DynamicRoute(provider: HomeContentProvider(context)),
        '/403': (context) => Error403(device),
        '/404': (context) => Error404(device)
      },
    );
  }
}

class HomeContentProvider implements RouteContentProvider {
  final BuildContext context;

  const HomeContentProvider(this.context);

  @override
  Future<String> getContent() {
    String url = _url();
    return Http.getInstance().post(url, null);
  }

  String _url() {
    String url;
    if (!accessToken.exists()) {
      url = environment.getOnboardUrl();
      logger.i('No access-token. home_url=$url');
    } else {
      if (accessToken.expired()) {
        url = _loginUrl();
        logger.i(
            'Expired access-token. phone=${accessToken.phoneNumber()} home_url=$url');
      } else {
        url = environment.getShellUrl();
        logger.i('Valid access-token. home_url=$url');
      }
    }
    return url;
  }

  String _loginUrl() {
    String? phone = accessToken.phoneNumber();
    return phone != null
        ? environment.getLoginUrl() + '?phone=$phone'
        : environment.getOnboardUrl();
  }
}
