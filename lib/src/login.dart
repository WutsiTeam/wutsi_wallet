import 'package:flutter/widgets.dart';
import 'package:sdui/sdui.dart';
import 'package:wutsi_wallet/src/environment.dart';

/// Login Page
class LoginContentProvider implements RouteContentProvider {
  final BuildContext context;
  final Environment environment;
  String? phoneNumber;
  bool? hideBackButton;

  LoginContentProvider(this.context, this.environment, {this.phoneNumber, this.hideBackButton});

  @override
  Future<String> getContent() => Http.getInstance()
      .post(loginUrl(phoneNumber, hideBackButton ?? false, environment), null);


  static String loginUrl(String? phoneNumber, bool hideBackButton, Environment environment) =>
      phoneNumber == null || phoneNumber.isEmpty
          ? environment.getOnboardUrl()
          : '${environment.getLoginUrl()}?phone=$phoneNumber&hide-back-button=$hideBackButton';
}

