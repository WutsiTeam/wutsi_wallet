import 'package:package_info/package_info.dart';
import 'package:sdui/sdui.dart';

class HttpPackageInfoInterceptor extends HttpInterceptor {
  PackageInfo packageInfo;

  HttpPackageInfoInterceptor(this.packageInfo);

  @override
  void onRequest(RequestTemplate request) async {
    request.headers['X-App-Name'] = packageInfo.appName;
    request.headers['X-App-Version'] = packageInfo.version;
    request.headers['X-App-Build-Number'] = packageInfo.buildNumber;
    request.headers['X-App-Package-Name'] = packageInfo.packageName;
  }

  @override
  void onResponse(ResponseTemplate response) {}
}
