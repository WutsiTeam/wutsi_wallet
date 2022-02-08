import 'package:logger/logger.dart';
import 'package:sdui/sdui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wutsi_wallet/src/access_token.dart';

class Environment {
  static const String _key = 'com.wutsi.env';
  static final Logger _logger = LoggerFactory.create('Environment');
  static const String defaultEnvironment = 'prod';

  String value = defaultEnvironment;

  Environment(this.value);

  static Future<Environment> get() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? value = preferences.getString(_key);
      return Environment(value ?? defaultEnvironment);
    } catch (e, stackTrace) {
      _logger.e('Unable to resolve the environment', e, stackTrace);
      return Environment(defaultEnvironment);
    }
  }

  Future<Environment> set(String value) async {
    // Set state
    this.value = value;

    // Store into preference
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(_key, value);

    return this;
  }

  String getGatewayUrl() => 'https://wutsi-gateway-$value.herokuapp.com';

  String getLoginUrl() => getGatewayUrl() + '/login';

  String getOnboardUrl() => getLoginUrl() + '/onboard';

  String getShellUrl() => getGatewayUrl() + '/shell';
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
