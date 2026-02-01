// lib/services/ad_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 広告管理サービス
class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();

  AdService._();

  bool _isInitialized = false;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  /// バナー広告が読み込まれているか
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  /// バナー広告
  BannerAd? get bannerAd => _bannerAd;

  /// AdMobを初期化
  Future<void> initialize() async {
    if (_isInitialized) return;

    await MobileAds.instance.initialize();
    _isInitialized = true;

    if (kDebugMode) {
      print('AdMob initialized');
    }
  }

  /// バナー広告のユニットID
  /// テスト用IDを使用（本番リリース時に変更）
  String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      // Android テスト用バナーID
      return 'ca-app-pub-3940256099942544/6300978111';
      //本番用
      // return 'ca-app-pub-1178983985791938/3328683835';
    } else if (Platform.isIOS) {
      // iOS テスト用バナーID
      return 'ca-app-pub-3940256099942544/2934735716';
      //本番用
      // return 'ca-app-pub-1178983985791938/1621012196';

      
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// バナー広告を読み込み
  Future<void> loadBannerAd({
    required Function() onLoaded,
    required Function(String error) onFailed,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // 既存の広告を破棄
    await _bannerAd?.dispose();
    _isBannerAdLoaded = false;

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
          onLoaded();
          if (kDebugMode) {
            print('Banner ad loaded');
          }
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdLoaded = false;
          ad.dispose();
          _bannerAd = null;
          onFailed(error.message);
          if (kDebugMode) {
            print('Banner ad failed to load: ${error.message}');
          }
        },
        onAdOpened: (ad) {
          if (kDebugMode) {
            print('Banner ad opened');
          }
        },
        onAdClosed: (ad) {
          if (kDebugMode) {
            print('Banner ad closed');
          }
        },
      ),
    );

    await _bannerAd!.load();
  }

  /// バナー広告を破棄
  Future<void> disposeBannerAd() async {
    await _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  /// 全ての広告を破棄
  Future<void> dispose() async {
    await disposeBannerAd();
  }
}
