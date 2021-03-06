import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';


class AnalyticsProvider {
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  late FirebaseAnalyticsObserver observer;
  AnalyticsProvider._internal() {
    observer = FirebaseAnalyticsObserver(analytics: analytics);
    analytics.logAppOpen();
  }

  static final AnalyticsProvider _singleton = AnalyticsProvider._internal();

  factory AnalyticsProvider() => _singleton;


  void setCurrentScreen(String screenName) {
    observer.analytics.setCurrentScreen(screenName: screenName, screenClassOverride: screenName);
  }

  void logSearch(String query) {
    analytics.logSearch(searchTerm: query);
  }

  void logLogin(String method) {
    analytics.logLogin(loginMethod: method);
  }

  void logRegister(String method) {
    analytics.logSignUp(signUpMethod: method);
  }

  void logShare(String method, String content, String itemId) {
    analytics.logShare(contentType: Platform.operatingSystem, itemId: itemId, method: method);
  }

  void logEvent(String event) {
    analytics.logEvent(name: event);
  }
}
