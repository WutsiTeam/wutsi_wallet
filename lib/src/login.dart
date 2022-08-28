import 'package:flutter/widgets.dart';
import 'package:sdui/sdui.dart';
import 'package:wutsi_wallet/src/environment.dart';

/// Login Page
class LoginContentProvider implements RouteContentProvider {
  final BuildContext context;
  final Environment environment;

  const LoginContentProvider(this.context, this.environment);

  @override
  Future<String> getContent() async {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, String?>{}) as Map;
    final phoneNumber = arguments['phone-number'];
    final hideBackButton = arguments['hide-back-button'];

    return Http.getInstance().post(loginUrl(phoneNumber, hideBackButton == 'true', environment), null);
  }

  static String loginUrl(String? phoneNumber, bool hideBackButton, Environment environment) =>
      phoneNumber == null || phoneNumber.isEmpty
          ? environment.getOnboardUrl()
          : '${environment.getLoginUrl()}?phone=$phoneNumber&hide-back-button=$hideBackButton';
}

