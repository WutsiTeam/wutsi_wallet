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
  void onResponse(ResponseTemplate response) async {
    String? value = response.headers['x-access-token'];
    if (value != null) {
      await _accessToken.set(value);
    }
  }
}
