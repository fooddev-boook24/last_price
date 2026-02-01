// lib/constants/sdk_config.dart
// ============================================================
// SDK設定ファイル
// 本番リリース前に以下のIDを実際の値に変更してください
// ============================================================

/// AdMob設定
class AdMobConfig {
  // Android
  // AndroidManifest.xml の com.google.android.gms.ads.APPLICATION_ID を変更
  // 現在: ca-app-pub-3940256099942544~3347511713 (テスト用)

  // iOS
  // ios/Runner/Info.plist の GADApplicationIdentifier を変更
  // 現在: ca-app-pub-3940256099942544~1458002511 (テスト用)

  // バナー広告ユニットID（lib/services/ad_service.dart で設定）
  // Android: ca-app-pub-3940256099942544/6300978111 (テスト用)
  // iOS: ca-app-pub-3940256099942544/2934735716 (テスト用)
}

/// AppsFlyer設定
class AppsFlyerConfigInfo {
  // lib/services/appsflyer_service.dart で設定
  // devKey: YOUR_APPSFLYER_DEV_KEY
  // appId: YOUR_APP_ID (iOS App Store ID、数字のみ)
}

/// In-App Purchase設定
class IAPConfigInfo {
  // lib/services/purchase_service.dart で設定
  // premiumProductId: 'last_price_premium'
  //
  // App Store Connect / Google Play Console で商品を作成:
  // - 商品ID: last_price_premium
  // - 種類: 非消費型（買い切り）
}

/// Firebase設定
class FirebaseConfigInfo {
  // すでに設定済み
  // - android/app/google-services.json
  // - ios/Runner/GoogleService-Info.plist
  // - lib/firebase_options.dart
}
