// import 'dart:convert';
// import 'dart:isolate';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart' show kDebugMode;
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:logger/logger.dart';
// import 'package:sdui/sdui.dart';
// import 'package:wutsi_wallet/src/access_token.dart';
// import 'package:wutsi_wallet/src/device.dart';
// import 'package:wutsi_wallet/src/environment.dart';
// import 'package:wutsi_wallet/src/event.dart';
// import 'package:sdui/sdui.dart' as sdui;

// final Logger _logger = LoggerFactory.create('firebase');
// String? _token;

// void initFirebase(Device device, Environment env) async {
//   await Firebase.initializeApp();
//   _initCrashlytics(device);
//   _initMessaging(env);
// }

// ///
// /// MESSAGING
// ///
// void _initMessaging(Environment env) async {
//   _logger.i('Initializing FirebaseMessaging');

//   // Event handlers
//   sdui.sduiFirebaseIconAndroid = '@mipmap/logo_192';
//   sdui.sduiFirebaseMessageHandler = (msg, foreground) {
//     _onRemoteMessage(msg, foreground);
//   };
//   sdui.sduiSelectionHandler = (payload, context) {
//     _onRemoteMessageSelected(payload, context);
//   };
//   sdui.sduiFirebaseTokenHandler = (token) {
//     _onToken(token);
//   };

//   // Login event handler
//   registerLoginEventHanlder((env) => _onLogin(env));
// }

// void _onRemoteMessage(RemoteMessage message, bool foreground) async {
//   // Show notification
//   await sduiLocalNotificationsPlugin.show(
//       message.hashCode,
//       message.notification?.title,
//       message.notification?.body,
//       const NotificationDetails(
//         android: AndroidNotificationDetails('wutsi_channel', 'wutsi_channel',
//             priority: Priority.max,
//             importance: Importance.max,
//             playSound: true,
//             icon: '@mipmap/logo_192'),
//         iOS: IOSNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//           badgeNumber: 1,
//           // attachments: List<IOSNotificationAttachment>?
//           // subtitle: String?,
//           // threadIdentifier: String?
//         ),
//       ),
//       payload: jsonEncode(message.data));

//   // Track
//   Environment.get().then((env) => Device.get().then((device) =>
//       Http.getInstance().post('${env.getShellUrl()}/firebase/on-message', {
//         'title': message.notification?.title,
//         'body': message.notification?.body,
//         'imageUrl': message.notification?.android?.imageUrl,
//         'data': message.data,
//         'background': !foreground
//       })));
// }

// void _onRemoteMessageSelected(String? payload, BuildContext context) {
//   if (payload == null) return;

//   var json = jsonDecode(payload);
//   if (json is Map<String, dynamic>) {
//     String? url = sdui.sduiDeeplinkHandler(json['url']);
//     if (url != null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//             builder: (context) =>
//                 DynamicRoute(provider: HttpRouteContentProvider(url))),
//       );
//     }
//   }
// }

// void _onToken(String? token) {
//   _token = token;
//   Environment.get().then((env) {
//     String url =
//         '${env.getShellUrl()}/commands/update-profile-attribute?name=fcm-token';
//     Http.getInstance().post(url, {'value': token});
//   });
// }

// void _onLogin(Environment env) async {
//   _onToken(_token);
// }

// ///
// /// CRASHLYTICS
// ///
// void _initCrashlytics(Device device) async {
//   _logger.i('Initializing FirebaseCrashlytics');

//   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
//   FirebaseCrashlytics.instance.setCustomKey("device_id", device.id);

//   Isolate.current.addErrorListener(RawReceivePort((pair) async {
//     final List<dynamic> errorAndStacktrace = pair;
//     await FirebaseCrashlytics.instance.recordError(
//       errorAndStacktrace.first,
//       errorAndStacktrace.last,
//     );
//   }).sendPort);

//   if (kDebugMode) {
//     // Force disable Crashlytics collection while doing every day development.
//     await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
//   }
// }

// /// HTTP interceptor for Crashlytics integration
// class HttpCrashlyticsInterceptor extends HttpInterceptor {
//   final Logger logger = LoggerFactory.create('HttpCrashlyticsInterceptor');
//   final AccessToken _accessToken;
//   final Environment _environment;

//   HttpCrashlyticsInterceptor(this._accessToken, this._environment);

//   @override
//   void onRequest(RequestTemplate request) {
//     try {
//       var crashlytics = FirebaseCrashlytics.instance;
//       if (crashlytics.isCrashlyticsCollectionEnabled) {
//         _setCustomKeyFromHeader(request, 'X-Trace-ID', 'trace_id');
//         _setCustomKey('request_body', request.body?.toString());
//         _setCustomKey("user_id", _accessToken.subject());
//         _setCustomKey("tenant_id", _environment.tenantId().toString());
//         _setCustomKey("env", _environment.value);
//       }
//     } catch (e) {
//       logger.e('Unable to initialize Crashlytics with request information', e);
//     }
//   }

//   @override
//   void onResponse(ResponseTemplate response) async {
//     var crashlytics = FirebaseCrashlytics.instance;
//     if (crashlytics.isCrashlyticsCollectionEnabled &&
//         response.statusCode / 100 > 2) {
//       _setCustomKey("http_url", response.request.url);
//       _setCustomKey("http_method", response.request.method);
//       _setCustomKey("http_status_code", response.statusCode.toString());
//       _setCustomKey("http_response", response.body);
//     }
//   }

//   void _setCustomKeyFromHeader(
//       RequestTemplate request, String header, String name) {
//     String? value = request.headers[name];
//     if (value != null) {
//       _setCustomKey(name, value);
//     }
//   }

//   void _setCustomKey(String name, String? value) {
//     if (value != null) {
//       FirebaseCrashlytics.instance.setCustomKey(name, value.toString());
//     }
//   }
// }

import 'dart:convert';
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
import 'package:wutsi_wallet/src/http.dart';

final Logger _logger = LoggerFactory.create('firebase');
String? _token;

void initFirebase(Environment env) async {
  await Firebase.initializeApp();

  _initCrashlytics();
  _initMessaging(env);
}

///
/// MESSAGING
///
void _initMessaging(Environment env) async {
  _logger.i('Initializing FirebaseMessaging');

  // Event handlers
  sdui.sduiFirebaseIconAndroid = '@mipmap/logo_192';
  sdui.sduiFirebaseMessageHandler = (msg, foreground) {
    _onRemoteMessage(msg, foreground);
  };
  sdui.sduiFirebaseOpenAppHandler = (msg, context) {
    _onOpenApp(msg, context);
  };
  sdui.sduiFirebaseTokenHandler = (token) {
    _onToken(token);
  };

  // Login event handler
  registerLoginEventHanlder((env) => _onLogin(env));
}

void _onRemoteMessage(RemoteMessage message, bool foreground) async {
  _logger.i(
      '_onRemoteMessage foreground=$foreground notification=${message.notification} data=${message.data}');

  // Show notification
  await sduiLocalNotificationsPlugin
      .show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        const NotificationDetails(
          android: AndroidNotificationDetails('wutsi_channel', 'wutsi_channel',
              priority: Priority.max,
              importance: Importance.max,
              playSound: true,
              icon: '@mipmap/logo_192'),
          iOS: IOSNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 1,
            // attachments: List<IOSNotificationAttachment>?
            // subtitle: String?,
            // threadIdentifier: String?
          ),
        ),
        payload: jsonEncode(message.data),
      )
      .then((value) => _track('/firebase/on-message', message, foreground));
}

void _onOpenApp(RemoteMessage message, BuildContext context) async {
  _logger.i('_onOpenApp data=${message.data}');

  // Handle
  String? url = sdui.sduiDeeplinkHandler(message.data['url']);
  if (url != null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              DynamicRoute(provider: HttpRouteContentProvider(url))),
    ).whenComplete(() => _track('/firebase/on-select', message, true));
  }
}

void _track(String endpoint, RemoteMessage message, bool foreground) {
  Environment.get().then((env) {
    if (!foreground) initHttp(env); // Init HTTP when handling background event

    Http.getInstance().post('${env.getShellUrl()}$endpoint', {
      'title': message.notification?.title,
      'body': message.notification?.body,
      'imageUrl': message.notification?.android?.imageUrl,
      'data': message.data,
      'background': !foreground
    });
  });
}

void _onToken(String? token) {
  _logger.i('onToken $token');

  _token = token;
  Environment.get().then((env) {
    String url =
        '${env.getShellUrl()}/commands/update-profile-attribute?name=fcm-token';
    Http.getInstance().post(url, {'value': token});
  });
}

void _onLogin(Environment env) async {
  _logger.i('onLogin');

  _onToken(_token);
}

///
/// CRASHLYTICS
///
void _initCrashlytics() async {
  _logger.i('Initializing FirebaseCrashlytics');

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

  HttpCrashlyticsInterceptor(this._accessToken, this._environment);

  @override
  void onRequest(RequestTemplate request) {
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
