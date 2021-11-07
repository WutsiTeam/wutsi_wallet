import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessToken {
  static const String _key = "com.wutsi.access_token";
  static String? _accessToken;

  static Future<String?> get() async {
    try {
      if (_accessToken == null) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        _accessToken = preferences.getString(_key);
      }
      return _accessToken;
    } catch (e) {
      return null;
    }
  }

  static void set(String value) async {
    _accessToken = value;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(_key, value);
  }

  static Future<Map<String, dynamic>?> decode() async {
    String? token = await get();
    if (token == null) {
      return null;
    } else {
      try {
        return JwtDecoder.decode(token);
      } catch (e) {
        return null;
      }
    }
  }
}
