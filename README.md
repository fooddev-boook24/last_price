# LAST PRICE

「前回より高く買う失敗を防ぐ」価格記録アプリ

## コンセプト

- 買う前 **3秒** で判断できることが最重要
- 思考を促さない / 判断を迷わせない
- 数字が主役、UIは極力沈黙

## 機能

### 無料版
- 商品登録：最大5件
- 価格記録・比較
- 価格差分の色表示（赤：値上がり / 緑：値下がり）

### Pro版（買い切り）
- 商品登録：無制限
- ピン留め機能
- 広告非表示

## プロジェクト構成

```
lib/
├── main.dart                    # エントリポイント
├── firebase_options.dart        # Firebase設定
├── first_open_provider.dart     # 初回起動検知
│
├── analytics/
│   └── app_analytics.dart       # Firebase Analytics
│
├── constants/
│   ├── app_constants.dart       # 定数
│   ├── app_theme.dart           # テーマ設定
│   └── sdk_config.dart          # SDK設定ガイド
│
├── models/
│   └── item.dart                # 商品モデル
│
├── providers/
│   ├── ad_provider.dart         # 広告状態管理
│   ├── items_provider.dart      # 商品一覧管理
│   └── premium_provider.dart    # 課金状態管理
│
├── screens/
│   ├── item_detail_screen.dart  # 商品詳細
│   ├── item_list_screen.dart    # 商品一覧（メイン）
│   └── settings_screen.dart     # 設定・課金
│
├── services/
│   ├── ad_service.dart          # AdMob
│   ├── appsflyer_service.dart   # AppsFlyer
│   ├── database_service.dart    # SQLite
│   └── purchase_service.dart    # RevenueCat
│
└── widgets/
    ├── add_item_sheet.dart      # 商品追加シート
    ├── banner_ad_widget.dart    # バナー広告
    ├── empty_state.dart         # 空状態
    ├── item_card.dart           # 商品カード
    └── update_price_sheet.dart  # 価格更新シート
```

## セットアップ

### 1. 依存関係のインストール

```bash
flutter pub get
```

### 2. iOS設定

```bash
cd ios && pod install && cd ..
```

### 3. 実行

```bash
flutter run
```

## SDK設定（本番リリース前）

### AdMob

1. **Android**: `android/app/src/main/AndroidManifest.xml`
   - `com.google.android.gms.ads.APPLICATION_ID` を変更

2. **iOS**: `ios/Runner/Info.plist`
   - `GADApplicationIdentifier` を変更

3. **広告ユニットID**: `lib/services/ad_service.dart`
   - `_bannerAdUnitId` を変更

### AppsFlyer

`lib/services/appsflyer_service.dart`:
- `devKey`: AppsFlyer Dev Key
- `appId`: iOS App Store ID（数字のみ）

### RevenueCat

`lib/services/purchase_service.dart`:
- `androidApiKey`: RevenueCat Android API Key
- `iosApiKey`: RevenueCat iOS API Key

RevenueCatダッシュボードで設定:
1. Entitlement ID: `premium`
2. Product ID: `last_price_premium`
3. App Store Connect / Google Play Console で商品を作成

## 計測イベント

### Firebase Analytics
- `first_open`: 初回起動
- `item_added`: 商品追加
- `price_updated`: 価格更新（差分・方向）
- `item_deleted`: 商品削除
- `paywall_shown`: 課金画面表示
- `purchase_completed`: 課金完了

### AppsFlyer
- インストール計測（オーガニック/非オーガニック判別）
- `item_added`: 商品追加
- `price_updated`: 価格更新
- `af_purchase`: 課金

## 技術スタック

- **Flutter** 3.6+
- **Riverpod** 2.6+ - 状態管理
- **SQLite** (sqflite) - ローカルDB
- **Firebase** - Analytics
- **AdMob** - 広告
- **AppsFlyer** - 流入計測
- **RevenueCat** - 課金管理

## ライセンス

Private - All rights reserved
