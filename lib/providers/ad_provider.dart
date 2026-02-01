// lib/providers/ad_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ad_service.dart';
import 'premium_provider.dart';

/// 広告の状態
class AdState {
  final bool isInitialized;
  final bool isBannerLoaded;
  final String? error;

  const AdState({
    this.isInitialized = false,
    this.isBannerLoaded = false,
    this.error,
  });

  AdState copyWith({
    bool? isInitialized,
    bool? isBannerLoaded,
    String? error,
  }) {
    return AdState(
      isInitialized: isInitialized ?? this.isInitialized,
      isBannerLoaded: isBannerLoaded ?? this.isBannerLoaded,
      error: error,
    );
  }
}

/// 広告を管理するNotifier
class AdNotifier extends StateNotifier<AdState> {
  final AdService _adService;

  AdNotifier(this._adService) : super(const AdState());

  /// 広告を初期化して読み込み
  Future<void> initialize() async {
    if (state.isInitialized) return;

    try {
      await _adService.initialize();
      state = state.copyWith(isInitialized: true);
      await loadBannerAd();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// バナー広告を読み込み
  Future<void> loadBannerAd() async {
    await _adService.loadBannerAd(
      onLoaded: () {
        state = state.copyWith(isBannerLoaded: true, error: null);
      },
      onFailed: (error) {
        state = state.copyWith(isBannerLoaded: false, error: error);
      },
    );
  }

  /// 広告を破棄
  Future<void> dispose() async {
    await _adService.dispose();
    state = const AdState();
  }
}

/// AdServiceのプロバイダー
final adServiceProvider = Provider<AdService>((ref) {
  return AdService.instance;
});

/// 広告状態のプロバイダー
final adProvider = StateNotifierProvider<AdNotifier, AdState>((ref) {
  final adService = ref.watch(adServiceProvider);
  return AdNotifier(adService);
});

/// 広告を表示すべきかどうか（無料ユーザーのみ）
final shouldShowAdProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  final adState = ref.watch(adProvider);
  return !isPremium && adState.isBannerLoaded;
});
