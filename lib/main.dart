import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sdui/sdui.dart';
import 'package:uni_links/uni_links.dart';
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
bool useDeeplink = true;

void main() async {
  // Flutter Screen of Death
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return FlutterErrorWidget(details: details);
  };

  // Run the app
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
  initAnalytics(environment);

  logger.i('Initializing Loading State');
  initLoadingState();

  logger.i('Initializing Error page');
  initError();

  logger.i('Initializing Contacts');
  initContacts('${environment.getShellUrl()}/commands/sync-contacts');

  // The app runs only in Portrait Mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const WutsiApp()));
}

class WutsiApp extends StatelessWidget {
  const WutsiApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wutsi Wallet',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [sduiRouteObserver],
      initialRoute: '/',
      routes: {
        '/': (context) => DynamicRoute(provider: HomeContentProvider(context)),
        '/login': (context) => DynamicRoute(provider: LoginContentProvider(context)),
      },
    );
  }
}

/// Home Page
class HomeContentProvider implements RouteContentProvider {
  final BuildContext context;

  HomeContentProvider(this.context);

  @override
  Future<String> getContent() async {
    String url = await _url();
    return Http.getInstance().post(url, null);
  }

  Future<String> _url() async {
    String url;

    logger.i('useDeeplink=$useDeeplink');
    if (!accessToken.exists()) {
      url = environment.getOnboardUrl();

      logger.i('No access-token. home_url=$url');
    } else {
      if (accessToken.expired()) {
        url = LoginContentProvider.loginUrl(accessToken.phoneNumber(), true);

        logger.i(
            'use_deep_link=$useDeeplink phone=${accessToken.phoneNumber()} home_url=$url');
      } else if (useDeeplink) {
        String? deepLink = await getInitialLink();
        url = _handleDeeplink(deepLink) ?? environment.getShellUrl();

        logger.i('use_deep_link=$useDeeplink deep_link=$deepLink home_url=$url');
      } else {
        url = environment.getShellUrl();

        logger.i('use_deep_link=$useDeeplink home_url=$url');
      }
    }

    useDeeplink = false; // Reset this to false so that deeplink is used only once by the home page
    return url;
  }

  String? _handleDeeplink(String? link) {
    if (link == null) {
      logger.i('Deeplink - null');
      return null;
    }

    String prefix = environment.getDeeplinkUrl().toLowerCase();
    int index = link.toLowerCase().indexOf(prefix);
    if (index != 0) {
      logger.i('Deeplink - $link doesnt start with $prefix');
      return null;
    }

    var uri = Uri.parse(link);
    var id = uri.queryParameters['id'];
    String? internalUrl;
    if (uri.path == '/profile') {
      internalUrl = '${environment.getShellUrl()}/profile?id=$id';
    } else if (uri.path == '/product') {
      internalUrl ='${environment.getStoreUrl()}/product?id=$id';
    } else if (uri.path == '/order') {
      internalUrl = '${environment.getStoreUrl()}/order?id=$id';
    } else if (uri.path == '/story/read') {
      internalUrl = '${environment.getNewsUrl()}/read?id=$id';
    }

    if (internalUrl != null) {
      if (uri.queryParameters['fbclid'] != null) {
        internalUrl += '&utm_source=facebook';
      }
    }

    logger.i('Deeplink - path=${uri.path} internal-url=$internalUrl');
    return internalUrl;
  }
}

/// Login Page
class LoginContentProvider implements RouteContentProvider {
  final BuildContext context;

  const LoginContentProvider(this.context);

  @override
  Future<String> getContent() async {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, String?>{}) as Map;
    final phoneNumber = arguments['phone-number'];
    final hideBackButton = arguments['hide-back-button'];

    return Http.getInstance().post(loginUrl(phoneNumber, hideBackButton == 'true'), null);
  }

  static String loginUrl(String? phoneNumber, bool hideBackButton) =>
      phoneNumber == null || phoneNumber.isEmpty
          ? environment.getOnboardUrl()
          : '${environment.getLoginUrl()}?phone=$phoneNumber&hide-back-button=$hideBackButton';
}
