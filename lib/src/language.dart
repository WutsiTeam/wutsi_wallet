import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:sdui/sdui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language {
  static const String _key = "com.wutsi.language";
  static final Logger _logger = LoggerFactory.create('Language');

  String value;

  Language(this.value);

  static Future<Language> get() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? value = preferences.getString(_key) ?? _defaultLanguage();
      return Language(value);
    } catch (e, stackTrace) {
      _logger.e('Unable to resolve the language', e, stackTrace);
      return Language(_defaultLanguage());
    }
  }

  static String _defaultLanguage() =>
      WidgetsBinding.instance.window.locale.languageCode;

  Future<Language> set(String value) async {
    this.value = value;

    // Store
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(_key, value);

    return this;
  }
}

/// HTTP interceptor that set the request header `Accept-Language` to the current user language
class HttpInternationalizationInterceptor extends HttpInterceptor {
  final Language _language;

  HttpInternationalizationInterceptor(this._language);

  @override
  void onRequest(RequestTemplate request) {
    request.headers[HttpHeaders.acceptLanguageHeader] = _language.value;
  }

  @override
  void onResponse(ResponseTemplate response) {
    String? value = response.headers['x-language'];
    if (value != null) {
      _language.set(value);
    }
  }
}
