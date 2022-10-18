import 'package:flutter/widgets.dart';
import 'package:sdui/sdui.dart';
import 'package:wutsi_wallet/src/environment.dart';

/// Login Page
class LoginContentProvider implements RouteContentProvider {
  final BuildContext context;
  String? phoneNumber;
  bool? hideBackButton;

  LoginContentProvider(this.context, {this.phoneNumber, this.hideBackButton});

  @override
  Future<String> getContent() => Environment.get()
      .then((value) => Http.getInstance()
        .post(loginUrl(phoneNumber, hideBackButton ?? false, value), null)
  );


  static String loginUrl(String? phoneNumber, bool hideBackButton, Environment environment) =>
      phoneNumber == null || phoneNumber.isEmpty
          ? environment.getOnboardUrl()
          : '${environment.getLoginUrl()}?phone=$phoneNumber&hide-back-button=$hideBackButton';
}

