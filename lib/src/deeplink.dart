import 'package:wutsi_wallet/src/environment.dart';
// import 'package:sdui/sdui.dart' as sdui;

void initDeeplink(Environment environment){
  // sdui.sduiDeeplinkHandler = (uri) {
  //   // Environment
  //   if (!uri.toString().startsWith(environment.getDeeplinkUrl())) {
  //     return null;
  //   }
  //
  //   // Chat
  //   if (uri.path == '/messages') {
  //     var recipientId = uri.queryParameters['recipient-id'];
  //     if (recipientId != null){
  //       return '${environment.getChatUrl()}/messages?recipient-id=$recipientId';
  //     } else {
  //       return null;
  //     }
  //   }
  //
  //   // ID based URL
  //   var id = uri.queryParameters['id'];
  //   if (id == null) {
  //     return null;
  //   }
  //   if (uri.path == '/profile') {
  //     return '${environment.getShellUrl()}/profile?id=$id';
  //   } else if (uri.path == '/product') {
  //     return'${environment.getStoreUrl()}/product?id=$id';
  //   } else if (uri.path == '/order') {
  //     return '${environment.getStoreUrl()}/order?id=$id';
  //   } else if (uri.path == '/transaction') {
  //     return '${environment.getCashUrl()}/transaction?id=$id';
  //   } else if (uri.path == '/story/read') {
  //     return '${environment.getNewsUrl()}/read?id=$id';
  //   } else{
  //     return null;
  //   }
  // };
}
