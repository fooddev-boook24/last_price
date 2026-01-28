// lib/app_analytics.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AppAnalytics {
  AppAnalytics._();

  static final FirebaseAnalytics _fa = FirebaseAnalytics.instance;

  /// 初回起動（アプリ人生で1回だけ送る想定）
  static Future<void> firstOpen() async {
    await _fa.logEvent(name: 'first_open');
  }
}
