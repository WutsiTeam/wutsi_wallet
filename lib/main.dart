import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:sdui/sdui.dart';
import 'package:wutsi_wallet/src/analytics.dart';
import 'package:wutsi_wallet/src/environment.dart';
import 'package:wutsi_wallet/src/error.dart';
import 'package:wutsi_wallet/src/event.dart';
import 'package:wutsi_wallet/src/firebase.dart';
import 'package:wutsi_wallet/src/http.dart';
import 'package:wutsi_wallet/src/loading.dart';
import 'package:wutsi_wallet/src/deeplink.dart';
import 'package:wutsi_wallet/src/login.dart';


final Logger logger = LoggerFactory.create('main');

Environment environment = Environment(Environment.defaultEnvironment);
bool useDeeplink = true;

void main() async {
  setupErrorHandling();
  WidgetsFlutterBinding.ensureInitialized();

  _launch();
}

void _launch() async {
  environment = await Environment.get();

  logger.i('Initializing HTTP');
  await initHttp(environment);

  logger.i('Initializing Events');
  initEvents(environment);

  logger.i('Initializing Firebase');
  initFirebase(environment);

  logger.i('Initializing Analytics');
  initAnalytics(environment);

  logger.i('Initializing Loading State');
  initLoadingState();

  logger.i('Initializing Deeplinks');
  initDeeplink(environment);

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
        '/': (context) => DynamicRoute(provider: HttpRouteContentProvider(environment.getShellUrl())),
        '/login': (context) => DynamicRoute(provider: LoginContentProvider(context), handleFirebaseMessages: false),
      },
    );
  }
}
