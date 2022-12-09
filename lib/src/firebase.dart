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
import 'package:sdui/sdui.dart' as sdui;

final Logger _logger = LoggerFactory.create('firebase');
String? _token;

void initFirebase(Environment env) async {
  try {
    await Firebase.initializeApp();

    _initCrashlytics();
    _initMessaging(env);
  } catch(ex){
    _logger.e('Firebase initialization error', ex);
  }
}

///
/// MESSAGING
///
void _initMessaging(Environment env) async {
  _logger.i('Initializing FirebaseMessaging');

  // Event handlers
  sdui.sduiFirebaseTokenHandler = (token){
    _onToken(token);
  };
  sdui.sduiFirebaseMessageHandler = (msg) {
    _onMessage(msg);
  };

  // Login event handler
  registerLoginEventHanlder((env) => _onLogin(env));
}

void _onToken(String? token) async {
  _logger.i('onToken $token');

  _token = token;
  Environment.get().then((env) {
    String url = '${env.getShellUrl()}/firebase/token';
    Http.getInstance().post(url, {'token': token!});
  });
}

void _onMessage(RemoteMessage message){
  _logger.i(
      '_onMessage id=${message.messageId} data=${message.data}');
}

void _onLogin(Environment env) async {
  _logger.i('onLogin');

  _onToken(_token);
}

///
/// CRASHLYTICS
///
void _initCrashlytics() async {
  if (kDebugMode) return;

  _logger.i('Initializing FirebaseCrashlytics');
  try {
    Device device = await Device.get();

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    FirebaseCrashlytics.instance.setCustomKey("device_id", device.id);

    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);
  } catch(ex){
    _logger.w("Unable to initialize Crashlytics", ex);
  }
}

/// HTTP interceptor for Crashlytics integration
class HttpCrashlyticsInterceptor extends HttpInterceptor {
  final Logger logger = LoggerFactory.create('HttpCrashlyticsInterceptor');
  final AccessToken _accessToken;
  final Environment _environment;

  HttpCrashlyticsInterceptor(this._accessToken, this._environment);

  @override
  void onRequest(RequestTemplate request) {
    if (kDebugMode) return;

    try {
      var crashlytics = FirebaseCrashlytics.instance;
      if (crashlytics.isCrashlyticsCollectionEnabled) {
        _setCustomKeyFromHeader(request, 'X-Trace-ID', 'trace_id');
        _setCustomKey('request_body', request.body?.toString());
        _setCustomKey("user_id", _accessToken.subject());
        _setCustomKey("tenant_id", _environment.tenantId().toString());
        _setCustomKey("env", _environment.value);
      }
    } catch (e) {
      logger.e('Unable to initialize Crashlytics with request information', e);
    }
  }

  @override
  void onResponse(ResponseTemplate response) async {
    if (kDebugMode) return;

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
