import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:sdui/sdui.dart';
import 'package:uuid/uuid.dart';
import 'package:wutsi_wallet/src/device.dart';
import 'package:wutsi_wallet/src/event.dart';

import 'access_token.dart';

void initHttp(String clientId, AccessToken accessToken, Device device) {
  Http.getInstance().interceptors = [
    HttpJsonInterceptor(),
    HttpAuthorizationInterceptor(accessToken),
    HttpTracingInterceptor(clientId, device.id, 1),
    HttpInternationalizationInterceptor(),
    HttpCrashlyticsInterceptor(accessToken),
  ];
}

/// Interceptor that add tracing information into the request headers.
/// The tracing information added are:
/// - `X-Device-ID`: ID of the device
/// - `X-Trace-ID`: ID that represent the interfaction trace
/// - `X-Client-ID`: Identification of the client application
class HttpTracingInterceptor extends HttpInterceptor {
  final String clientId;
  final String deviceId;
  final int tenantId;

  HttpTracingInterceptor(this.clientId, this.deviceId, this.tenantId);

  @override
  void onRequest(RequestTemplate request) async {
    request.headers['X-Device-ID'] = clientId;
    request.headers['X-Trace-ID'] = const Uuid().v1();
    request.headers['X-Device-ID'] = deviceId;
    request.headers['X-Tenant-ID'] = tenantId.toString();
  }

  @override
  void onResponse(ResponseTemplate response) {}
}

/// HTTP interceptor that set the request header `Accept-Language` to the current user language
class HttpInternationalizationInterceptor extends HttpInterceptor {
  @override
  void onRequest(RequestTemplate request) {
    request.headers[HttpHeaders.acceptLanguageHeader] = _language();
  }

  @override
  void onResponse(ResponseTemplate response) {}

  String _language() =>
      WidgetsBinding.instance?.window.locale.languageCode ?? 'en';
}

/// HTTP interceptor that adds Authorization header
class HttpAuthorizationInterceptor extends HttpInterceptor {
  final AccessToken _accessToken;

  HttpAuthorizationInterceptor(this._accessToken);

  @override
  void onRequest(RequestTemplate request) {
    if (_accessToken.value != null) {
      request.headers['Authorization'] = 'Bearer ${_accessToken.value}';
    }
  }

  @override
  void onResponse(ResponseTemplate response) {
    String? value = response.headers['x-access-token'];
    if (value != null) {
      _accessToken
          .set(value)
          .then((value) => eventBus.fire(UserLoggedInEvent(_accessToken)));
    }
  }
}

/// HTTP interceptor for Crashlytics integration
class HttpCrashlyticsInterceptor extends HttpInterceptor {
  final AccessToken _accessToken;

  HttpCrashlyticsInterceptor(this._accessToken);

  @override
  void onRequest(RequestTemplate request) {}

  @override
  void onResponse(ResponseTemplate response) async {
    var crashlytics = FirebaseCrashlytics.instance;
    if (crashlytics.isCrashlyticsCollectionEnabled &&
        response.statusCode / 100 > 2) {
      String? userId = _accessToken.subject();
      if (userId != null) {
        crashlytics.setCustomKey("user_id", userId);
      }

      crashlytics.setCustomKey("http_url", response.request.url);
      crashlytics.setCustomKey("http_method", response.request.method);
      crashlytics.setCustomKey("http_status_code", response.statusCode);
      crashlytics.setCustomKey("http_response", response.body);
      if (response.request.body != null) {
        crashlytics.setCustomKey("http_request", response.request.body!);
      }
    }
  }
}
