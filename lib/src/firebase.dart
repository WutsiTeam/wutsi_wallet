import 'dart:io';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:sdui/sdui.dart';
import 'package:wutsi_wallet/src/access_token.dart';
import 'package:wutsi_wallet/src/device.dart';
import 'package:wutsi_wallet/src/environment.dart';
import 'package:wutsi_wallet/src/event.dart';
import 'package:sdui/sdui.dart' as sdui;

final Logger _logger = LoggerFactory.create('firebase');

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'default_notification_channel_id',
  'Wutsi_Notification', // name
  description: 'This is a channel for Wutsi notification.', // description
  importance: Importance.max,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void initFirebase(Device device, Environment env) {
  Firebase.initializeApp().then((app) {
    _initCrashlytics(device);
    _initMessaging(env);
  });
}

///
/// MESSAGING
///
void _initMessaging(Environment env) async {
  _logger.i('Initializing FirebaseMessaging');

  // Event handling - background and foreground
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  sdui.sduiFirebaseMessagingHandler = (msg){
    _showNotification(msg);
  };

  // Create channel
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Login event handler
  registerLoginEventHanlder((env) => _onLogin(env));
}

Future<void> _onBackgroundMessage(RemoteMessage message) async{
  Logger logger = LoggerFactory.create('firebase-background');
  logger.i('Background - Message received: ${message.messageId}');

  _showNotification(message);
}

void _showNotification(RemoteMessage message){
  flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          priority: Priority.max,
          importance: Importance.max,
          playSound: true,
        ),
      ));
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

