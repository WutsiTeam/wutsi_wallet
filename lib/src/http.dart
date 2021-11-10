import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:sdui/sdui.dart';
import 'package:uuid/uuid.dart';

import 'access_token.dart';

/// Interceptor that add tracing information into the request headers.
/// The tracing information added are:
/// - `X-Device-ID`: ID of the device
/// - `X-Trace-ID`: ID that represent the interfaction trace
/// - `X-Client-ID`: Identification of the client application
class HttpTracingInterceptor extends HttpInterceptor {
  static const String headerDeviceId = 'X-Device-ID';
  static const String headerTraceId = 'X-Trace-ID';
  static const String headerClientId = 'X-Client-ID';

  String clientId = '';
  String deviceId = '';

  HttpTracingInterceptor(this.clientId, this.deviceId);

  @override
  void onRequest(RequestTemplate request) async {
    request.headers[headerClientId] = clientId;
    request.headers[headerTraceId] = const Uuid().v1();
    request.headers[headerDeviceId] = deviceId;
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
      _accessToken.set(value);
    }
  }
}
