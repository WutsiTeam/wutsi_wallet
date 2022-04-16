import 'package:sdui/sdui.dart' as sdui;
import 'package:logger/logger.dart';
import 'environment.dart';

void initAnalytics(Environment environment) async {
  sdui.sduiAnalytics = _SDUIAnalyticsImpl(environment);
}

class _SDUIAnalyticsImpl extends sdui.SDUIAnalytics {
  static final Logger _logger = sdui.LoggerFactory.create('_SDUIAnalyticsImpl');
  String _trackUrl = '';

  _SDUIAnalyticsImpl(Environment environment){
    _trackUrl = environment.getShellUrl() + '/track';
  }

  @override
  void onRoute(String screenId) {
    _logger.i('onRoute screenId=$screenId');
    sdui.Http.getInstance().post('$_trackUrl/load?screen-id=$screenId', null);
  }

  @override
  void onAction(String screenId, String event, String? productId) {
    _logger.i('onAction screenId=$screenId event=$event productId=$productId');
    sdui.Http.getInstance().post('$_trackUrl/action?screen-id=$screenId', {
      'event': event,
      'productId': productId
    });
  }
}
