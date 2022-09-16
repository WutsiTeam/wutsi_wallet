import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sdui/sdui.dart';
import 'package:wutsi_wallet/src/access_token.dart';
import 'package:wutsi_wallet/src/device.dart';
import 'package:wutsi_wallet/src/environment.dart';
import 'package:wutsi_wallet/src/event.dart';

final Logger _logger = LoggerFactory.create('firebase');

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel',
//   'High Importance Notifications', // name
//   description: 'This channel is used for important notifications.', // description
//   importance: Importance.max,
// );

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void initFirebase(Device device, Environment env) async {
  _logger.i('Initializing Firebase');
  await Firebase.initializeApp();

  _initCrashlytics(device);
  _initMessaging(env);
}

///
/// MESSAGING
///
void _initMessaging(Environment env) async {
  _logger.i('Initializing FirebaseMessaging');

  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  registerLoginEventHanlder((env) => _onLogin(env));
}

Future _onBackgroundMessage(RemoteMessage message) async {
  _logger.i('Background - Message received: $message');
  _showNotification(message, true);
}

void _showNotification(RemoteMessage message, bool background) async{
  final Logger logger = LoggerFactory.create('firebase');

  // Send notification - Useful for tracking and debugging purpose
  logger.i('Tracking notification...');
  Environment.get().then((env) =>
      Device.get().then((device) =>
          Http.getInstance().post(
              '${env.getShellUrl()}/firebase/on-message',
              {
                'title': message.notification?.title,
                'body': message.notification?.body,
                'imageUrl': message.notification?.android?.imageUrl,
                'data': message.data,
                'background': background,
                'deviceId': device.id
              }
          )
      )
  );

  // // Send notification to channel
  // logger.i('creating the channel...');
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);
  //
  // logger.i('showing notification...');
  // flutterLocalNotificationsPlugin.show(
  //     message.hashCode,
  //     message.notification?.title,
  //     message.notification?.body,
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         channel.id,
  //         channel.name,
  //         channelDescription: channel.description,
  //         icon: message.notification?.android?.smallIcon,
  //         priority: Priority.max,
  //         importance: Importance.max,
  //         playSound: true
  //       ),
  //     ));
}

void _onLogin(Environment env) async {
  FirebaseMessaging fb = FirebaseMessaging.instance;

  NotificationSettings settings = await fb.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    // Get the token
    fb.getToken().then((value) {
      _logger.i('Syncing User FCM Token - token=$value');
      String url = '${env.getShellUrl()}/commands/update-profile-attribute?name=fcm-token';
      Http.getInstance().post(url, {'value': value});
    });

    // Listen to events
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i('Foreground - Message received: $message');
      _showNotification(message, false);
    });
  } else {
    _logger.i('User declined or has not accepted permission');
  }
}

///
/// CRASHLYTICS
///
void _initCrashlytics(Device device) async {
  _logger.i('Initializing FirebaseCrashlytics');

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FirebaseCrashlytics.instance.setCustomKey("device_id", device.id);

  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);

  if (kDebugMode) {
    // Force disable Crashlytics collection while doing every day development.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }
}

/// HTTP interceptor for Crashlytics integration
class HttpCrashlyticsInterceptor extends HttpInterceptor {
  final Logger logger = LoggerFactory.create('HttpCrashlyticsInterceptor');
  final AccessToken _accessToken;
  final Environment _environment;
  final int tenantId;

  HttpCrashlyticsInterceptor(
      this._accessToken, this._environment, this.tenantId);

  @override
  void onRequest(RequestTemplate request) {
    try {
      var crashlytics = FirebaseCrashlytics.instance;
      if (crashlytics.isCrashlyticsCollectionEnabled) {
        _setCustomKeyFromHeader(request, 'X-Trace-ID', 'trace_id');
        _setCustomKey('request_body', request.body?.toString());
        _setCustomKey("user_id", _accessToken.subject());
        _setCustomKey("tenant_id", tenantId.toString());
        _setCustomKey("env", _environment.value);
      }
    } catch (e) {
      logger.e('Unable to initialize Crashlytics with request information', e);
    }
  }

  @override
  void onResponse(ResponseTemplate response) async {
    var crashlytics = FirebaseCrashlytics.instance;
    if (crashlytics.isCrashlyticsCollectionEnabled &&
        response.statusCode / 100 > 2) {
      _setCustomKey("http_url", response.request.url);
      _setCustomKey("http_method", response.request.method);
      _setCustomKey("http_status_code", response.statusCode.toString());
      _setCustomKey("http_response", response.body);
    }
  }

  void _setCustomKeyFromHeader(
      RequestTemplate request, String header, String name) {
    String? value = request.headers[name];
    if (value != null) {
      _setCustomKey(name, value);
    }
  }

  void _setCustomKey(String name, String? value) {
    if (value != null) {
      FirebaseCrashlytics.instance.setCustomKey(name, value.toString());
    }
  }
}

