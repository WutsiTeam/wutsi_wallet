import 'package:package_info_plus/package_info_plus.dart';
import 'package:sdui/sdui.dart';

class HttpPackageInfoInterceptor extends HttpInterceptor {
  PackageInfo? _packageInfo;

  @override
  void onRequest(RequestTemplate request) async {
    PackageInfo pi = await _loadPackageInfo();
    request.headers['X-App-Name'] = pi.appName;
    request.headers['X-App-Version'] = pi.version;
    request.headers['X-App-Build-Number'] = pi.buildNumber;
    request.headers['X-App-Package-Name'] = pi.packageName;
  }

  @override
  void onResponse(ResponseTemplate response) {}

  Future<PackageInfo> _loadPackageInfo() async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return _packageInfo!;
  }
}
