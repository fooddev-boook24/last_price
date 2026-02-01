// lib/services/appsflyer_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

/// AppsFlyer設定
/// 本番リリース時に実際のDev Keyに変更してください
class AppsFlyerConfig {
  // TODO: 本番リリース時に実際のDev Keyに変更
  static const String devKey = 'TjwZHGeshH4VxhaDo9wSc5';

  // TODO: iOSの場合、App IDを設定（数字のみ、例：123456789）
  static const String appId = '6758384602';
}

/// AppsFlyer計測サービス
class AppsFlyerService {
  static AppsFlyerService? _instance;
  static AppsFlyerService get instance => _instance ??= AppsFlyerService._();

  AppsFlyerService._();

  AppsflyerSdk? _appsflyerSdk;
  bool _isInitialized = false;

  /// 初期化済みかどうか
  bool get isInitialized => _isInitialized;

  /// AppsFlyerを初期化
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Dev Keyが設定されていない場合はスキップ
    if (AppsFlyerConfig.devKey == 'TjwZHGeshH4VxhaDo9wSc5') {
      if (kDebugMode) {
        print('AppsFlyer: Dev Key not configured, skipping initialization');
      }
      return;
    }

    final options = AppsFlyerOptions(
      afDevKey: AppsFlyerConfig.devKey,
      appId: Platform.isIOS ? AppsFlyerConfig.appId : '',
      showDebug: kDebugMode,
      timeToWaitForATTUserAuthorization: 10, // iOS ATT待機時間
    );

    _appsflyerSdk = AppsflyerSdk(options);

    // コールバックを設定
    _appsflyerSdk!.onInstallConversionData((data) {
      if (kDebugMode) {
        print('AppsFlyer onInstallConversionData: $data');
      }
      _handleConversionData(data);
    });

    _appsflyerSdk!.onAppOpenAttribution((data) {
      if (kDebugMode) {
        print('AppsFlyer onAppOpenAttribution: $data');
      }
    });

    _appsflyerSdk!.onDeepLinking((result) {
      if (kDebugMode) {
        print('AppsFlyer onDeepLinking: ${result.status}');
      }
    });

    // SDKを開始
    await _appsflyerSdk!.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    _isInitialized = true;

    if (kDebugMode) {
      print('AppsFlyer initialized');
    }
  }

  /// コンバージョンデータを処理
  void _handleConversionData(Map<String, dynamic> data) {
    // オーガニック / 非オーガニックの判別
    final status = data['af_status'] as String?;
    final isOrganic = status == 'Organic';

    if (kDebugMode) {
      print('AppsFlyer install type: ${isOrganic ? "Organic" : "Non-Organic"}');
      if (!isOrganic) {
        final mediaSource = data['media_source'];
        final campaign = data['campaign'];
        print('AppsFlyer media_source: $mediaSource, campaign: $campaign');
      }
    }
  }

  /// カスタムイベントを送信
  Future<void> logEvent(String eventName, Map<String, dynamic>? eventValues) async {
    if (!_isInitialized || _appsflyerSdk == null) return;

    try {
      await _appsflyerSdk!.logEvent(eventName, eventValues);
      if (kDebugMode) {
        print('AppsFlyer event logged: $eventName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppsFlyer event error: $e');
      }
    }
  }

  /// 購入イベントを送信
  Future<void> logPurchase({
    required String productId,
    required double price,
    required String currency,
  }) async {
    await logEvent('af_purchase', {
      'af_content_id': productId,
      'af_revenue': price,
      'af_currency': currency,
    });
  }

  /// 商品追加イベントを送信
  Future<void> logItemAdded() async {
    await logEvent('item_added', null);
  }

  /// 価格更新イベントを送信
  Future<void> logPriceUpdated({required int priceDiff}) async {
    await logEvent('price_updated', {
      'price_diff': priceDiff,
    });
  }
}
