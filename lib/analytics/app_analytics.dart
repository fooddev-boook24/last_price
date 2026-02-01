// lib/analytics/app_analytics.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AppAnalytics {
  AppAnalytics._();

  static final FirebaseAnalytics _fa = FirebaseAnalytics.instance;

  /// 初回起動（アプリ人生で1回だけ送る想定）
  static Future<void> firstOpen() async {
    await _fa.logEvent(name: 'first_open');
  }

  /// 商品追加
  static Future<void> itemAdded() async {
    await _fa.logEvent(name: 'item_added');
  }

  /// 価格更新
  static Future<void> priceUpdated({required int priceDiff}) async {
    await _fa.logEvent(
      name: 'price_updated',
      parameters: {
        'price_diff': priceDiff,
        'direction': priceDiff > 0
            ? 'up'
            : priceDiff < 0
                ? 'down'
                : 'same',
      },
    );
  }

  /// 課金画面表示
  static Future<void> paywallShown() async {
    await _fa.logEvent(name: 'paywall_shown');
  }

  /// 課金完了
  static Future<void> purchaseCompleted() async {
    await _fa.logEvent(name: 'purchase_completed');
  }

  /// 商品削除
  static Future<void> itemDeleted() async {
    await _fa.logEvent(name: 'item_deleted');
  }
}
