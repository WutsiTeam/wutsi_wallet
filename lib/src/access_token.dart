import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import 'package:sdui/sdui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wutsi_wallet/src/event.dart';

class AccessToken {
  static const String _key = "com.wutsi.access_token";
  static final Logger _logger = LoggerFactory.create('AccessToken');

  String? value;
  Map<String, dynamic> _claims;

  AccessToken(this.value, this._claims);

  static Future<AccessToken> get() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString(_key);
      if (token == null) {
        return AccessToken(null, {});
      } else {
        return AccessToken(token, JwtDecoder.decode(token));
      }
    } catch (e, stackTrace) {
      _logger.e('Unable to resolve the access_token', e, stackTrace);
      return AccessToken(null, {});
    }
  }

  Future<AccessToken> set(String value) async {
    // Set state
    this.value = value;
    _claims = JwtDecoder.decode(value);

    // Store into preference
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(_key, value);

    return this;
  }

  Future<AccessToken> delete() async {
    // Clear state
    value = null;
    _claims = {};

    // Remove from preferences
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(_key);

    return this;
  }

  bool exists() => value != null;

  bool expired() {
    if (value == null) {
      return true;
    } else {
      DateTime expires = JwtDecoder.getExpirationDate(value!);
      return expires.isBefore(DateTime.now());
    }
  }

  String? phoneNumber() => _claims['phone_number'];

  String? subject() => _claims['sub'];
}

/// HTTP interceptor that adds Authorization header
class HttpAuthorizationInterceptor extends HttpInterceptor {
  static final Logger _logger =
      LoggerFactory.create('HttpAuthorizationInterceptor');
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
      _logger.i('access-token: $value');
      _accessToken
          .set(value)
          .then((value) => eventBus.fire(UserLoggedInEvent(_accessToken)));
    }
  }
}
