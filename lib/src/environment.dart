import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:logger/logger.dart';
import 'package:sdui/sdui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wutsi_wallet/src/access_token.dart';

class Environment {
  static const String _key = 'com.wutsi.env';
  static final Logger _logger = LoggerFactory.create('Environment');
  static const String defaultEnvironment = kDebugMode ? 'test' : 'prod';

  String value = defaultEnvironment;

  Environment(this.value);

  static Future<Environment> get() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String value = (preferences.containsKey(_key) ? preferences.getString(_key) : null) ?? defaultEnvironment;
      _logger.i('environment=$value');
      return Environment(value);
  }

  Future<Environment> set(String value) async {
    // Set state
    this.value = value;

    // Store into preference
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(_key, value);

    return this;
  }

  String clientId() => 'wutsi-wallet';

  int tenantId() => 1;

  String getShellUrl() =>  'https://wutsi-shell-bff-$value.herokuapp.com';

  String getHomeUrl() => value == 'test' ? "${getShellUrl()}/2" : getShellUrl();

  String getLoginUrl() =>  value == 'test' ? '${getShellUrl()}/login/2' : '${getShellUrl()}/login';

  String getOnboardUrl() => value == 'test' ? '${getShellUrl()}/onboard/2' : '${getShellUrl()}/onboard';

  String getCashUrl() =>  getShellUrl();

  String getStoreUrl() => getShellUrl();

  String getChatUrl() =>  'https://wutsi-chat-bff-$value.herokuapp.com';

  String getNewsUrl() => 'https://wutsi-news-bff-$value.herokuapp.com';

  String getDeeplinkUrl() => value == 'test'
      ? 'https://wutsi-web-test.herokuapp.com'
      : 'https://www.wutsi.me';
}

class HttpEnvironmentInterceptor extends HttpInterceptor {
  static final Logger _logger =
      LoggerFactory.create('HttpEnvironmentInterceptor');
  final Environment _environment;
  final AccessToken _accessToken;

  HttpEnvironmentInterceptor(this._environment, this._accessToken);

  @override
  void onRequest(RequestTemplate request) {
    request.headers['X-Environment'] = _environment.value;
  }

  @override
  void onResponse(ResponseTemplate response) {
    String? value = response.headers['x-environment'];
    if (value != null) {
      _logger.i('Environment: $value');

      _accessToken.delete();
      _environment.set(value);
    }
  }
}
