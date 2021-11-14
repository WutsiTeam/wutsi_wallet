import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import 'package:sdui/sdui.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    this.value = value;
    _claims = JwtDecoder.decode(value);

    // Store
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(_key, value);

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

  String? subject() => _claims['subject'];
}
