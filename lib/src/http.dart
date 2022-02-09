import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:sdui/sdui.dart';
import 'package:uuid/uuid.dart';

import 'access_token.dart';
import 'crashlytics.dart';
import 'device.dart';
import 'environment.dart';
import 'language.dart';

void initHttp(
    String clientId,
    AccessToken accessToken,
    Device device,
    Language language,
    int tenantId,
    PackageInfo packageInfo,
    Environment environment) {
  Http.getInstance().interceptors = [
    HttpJsonInterceptor(),
    HttpTracingInterceptor(clientId, device.id, tenantId, packageInfo),
    HttpInternationalizationInterceptor(language),
    HttpAuthorizationInterceptor(accessToken),
    HttpLogoutInterceptor(accessToken),
    HttpCrashlyticsInterceptor(accessToken, environment, tenantId),
    HttpEnvironmentInterceptor(environment, accessToken)
  ];

  DynamicRouteState.statusCodeRoutes[401] = '/401';
  DynamicRouteState.statusCodeRoutes[403] = '/403';
  DynamicRouteState.statusCodeRoutes[404] = '/404';
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
  final PackageInfo packageInfo;

  HttpTracingInterceptor(
      this.clientId, this.deviceId, this.tenantId, this.packageInfo);

  @override
  void onRequest(RequestTemplate request) {
    request.headers['X-Client-ID'] = clientId;
    request.headers['X-Trace-ID'] = const Uuid().v1().toString();
    request.headers['X-Device-ID'] = deviceId;
    request.headers['X-Tenant-ID'] = tenantId.toString();

    request.headers['X-Client-Version'] =
        '${packageInfo.version}.${packageInfo.buildNumber}';
    request.headers['X-OS'] = Platform.operatingSystem;
    request.headers['X-OS-Version'] = Platform.operatingSystemVersion;
  }

  @override
  void onResponse(ResponseTemplate response) {}
}
