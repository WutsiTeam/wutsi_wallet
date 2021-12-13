import 'package:sdui/sdui.dart';
import 'package:uuid/uuid.dart';
import 'package:wutsi_wallet/src/crashlytics.dart';
import 'package:wutsi_wallet/src/device.dart';

import 'access_token.dart';
import 'language.dart';

void initHttp(String clientId, AccessToken accessToken, Device device,
    Language language) {
  Http.getInstance().interceptors = [
    HttpJsonInterceptor(),
    HttpAuthorizationInterceptor(accessToken),
    HttpTracingInterceptor(clientId, device.id, 1),
    HttpInternationalizationInterceptor(language),
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
    request.headers['X-Client-ID'] = clientId;
    request.headers['X-Trace-ID'] = const Uuid().v1().toString();
    request.headers['X-Device-ID'] = deviceId;
    request.headers['X-Tenant-ID'] = tenantId.toString();
  }

  @override
  void onResponse(ResponseTemplate response) {}
}
