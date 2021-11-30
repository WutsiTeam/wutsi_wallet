import 'package:event_bus/event_bus.dart';
import 'package:wutsi_wallet/src/access_token.dart';

EventBus eventBus = EventBus();

class UserLoggedInEvent {
  final AccessToken accessToken;

  const UserLoggedInEvent(this.accessToken);
}
