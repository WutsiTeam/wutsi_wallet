import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:sdui/sdui.dart';
import 'package:uuid/uuid.dart';
import 'package:wutsi_wallet/src/firebase.dart';

import 'access_token.dart';
import 'device.dart';
import 'environment.dart';
import 'language.dart';

void initHttp(
    AccessToken accessToken,
    Device device,
    Language language,
    PackageInfo packageInfo,
    Environment environment) {
  Http.getInstance().interceptors = [
    HttpJsonInterceptor(),
    HttpTracingInterceptor(environment, device, packageInfo),
    HttpInternationalizationInterceptor(language),
    HttpAuthorizationInterceptor(accessToken),
    HttpCrashlyticsInterceptor(accessToken, environment),
    HttpEnvironmentInterceptor(environment, accessToken)
  ];
}

/// Interceptor that add tracing information into the request headers.
/// The tracing information added are:
/// - `X-Device-ID`: ID of the device
/// - `X-Trace-ID`: ID that represent the interfaction trace
/// - `X-Client-ID`: Identification of the client application
class HttpTracingInterceptor extends HttpInterceptor {
  final Environment _environment;
  final Device _device;
  final PackageInfo _packageInfo;

  HttpTracingInterceptor(
      this._environment, this._device, this._packageInfo);

  @override
  void onRequest(RequestTemplate request) {
    request.headers['X-Client-ID'] = _environment.clientId();
    request.headers['X-Trace-ID'] = const Uuid().v1().toString();
    request.headers['X-Device-ID'] = _device.id;
    request.headers['X-Tenant-ID'] = _environment.tenantId().toString();

    request.headers['X-Client-Version'] =
        '${_packageInfo.version}.${_packageInfo.buildNumber}';
    request.headers['X-OS'] = Platform.operatingSystem;
    request.headers['X-OS-Version'] = Platform.operatingSystemVersion;
  }

  @override
  void onResponse(ResponseTemplate response) {}
}
