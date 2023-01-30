import 'package:flutter/widgets.dart';
import 'package:sdui/sdui.dart';
import 'package:wutsi_wallet/src/access_token.dart';
import 'package:wutsi_wallet/src/environment.dart';

/// Login Page
class LoginContentProvider implements RouteContentProvider {
  final BuildContext context;
  bool? hideBackButton;

  LoginContentProvider(this.context, {this.hideBackButton});

  @override
  Future<String> getContent() => AccessToken.get()
      .then((token) => Environment.get()
        .then((env) => Http.getInstance()
        .post(loginUrl(token.phoneNumber(), hideBackButton ?? false, env), null)));


  String loginUrl(String? phoneNumber, bool hideBackButton, Environment environment) =>
      phoneNumber == null || phoneNumber.isEmpty
          ? environment.getOnboardUrl()
          : '${environment.getLoginUrl()}?phone=$phoneNumber&hide-back-button=$hideBackButton';
}

