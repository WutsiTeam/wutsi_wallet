import 'package:event_bus/event_bus.dart';
import 'package:logger/logger.dart';
import 'package:sdui/sdui.dart';
import 'package:wutsi_wallet/src/access_token.dart';
import 'package:wutsi_wallet/src/environment.dart';

typedef EventHandler = void Function(Environment env);

EventBus eventBus = EventBus();
List<EventHandler> _loginEventHandlers = [];
Logger _logger = LoggerFactory.create('event');

class UserLoggedInEvent {
  final AccessToken accessToken;
  const UserLoggedInEvent(this.accessToken);
}

void registerLoginEventHanlder(EventHandler handler){
  _loginEventHandlers.add(handler);
}

void initEvents(Environment env){
  eventBus.on<UserLoggedInEvent>().listen((event) => _onLogin(env));
}

void _onLogin(Environment env){
  for (var it in _loginEventHandlers) {
    try {
      it(env);
    } catch(ex){
      _logger.e('Error handling event', ex);
    }
  }
}
