import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:logger/logger.dart';
import 'package:sdui/sdui.dart' as sdui;
import 'package:wutsi_wallet/src/access_token.dart';
import 'package:wutsi_wallet/src/device.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics();
final FirebaseAnalyticsObserver analyticsObserver =
    FirebaseAnalyticsObserver(analytics: analytics);

void initAnalytics(AccessToken accessToken, Device device) async {
  sdui.sduiAnalytics = _SDUIAnalyticsImpl(accessToken, device);

  if (kDebugMode) {
    // Force disable Analytics collection while doing every day development.
    analytics.setAnalyticsCollectionEnabled(false);
  }
}

class _SDUIAnalyticsImpl extends sdui.SDUIAnalytics {
  final Device device;
  final AccessToken accessToken;
  final Logger _logger = sdui.LoggerFactory.create('_SDUIAnalyticsImpl');

  _SDUIAnalyticsImpl(this.accessToken, this.device);

  @override
  void onRoute(String id) {
    _initProperties();
    analytics.setCurrentScreen(screenName: id);
  }

  @override
  void onClick(String id) {
    _initProperties();
    analytics.logEvent(name: id);
  }

  @override
  dynamic startTrace(String id) {
    // Disable performance tracing in debug-mode
    if (kDebugMode) return null;

    try {
      Trace trace = FirebasePerformance.instance.newTrace(id);
      trace.start();

      print('startTrace: $id - $trace');
      return trace;
    } catch(ex){
      _logger.e('Unable to start the trace: $id', ex);
      return null;
    }
  }

  @override
  void endTrace(dynamic trace) {
    // Disable performance tracing in debug-mode
    if (kDebugMode) return null;

    try {
      print('endTrace: $trace');

      if (trace is Trace) {
        trace.stop();
      }
    } catch(ex){
      _logger.e('Unable to end the trace: $trace', ex);
    }
  }

  void _initProperties() {
    analytics.setUserId(accessToken.subject());
    analytics.setUserProperty(name: "device_id", value: device.id);
  }
}
