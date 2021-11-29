import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
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

  void _initProperties() {
    analytics.setUserId(accessToken.subject());
    analytics.setUserProperty(name: "device_id", value: device.id);
  }
}
