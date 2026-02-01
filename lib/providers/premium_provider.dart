// lib/providers/premium_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/purchase_service.dart';

/// 課金状態
class PremiumState {
  final bool isPremium;
  final bool isLoading;
  final String? priceText;
  final String? error;

  const PremiumState({
    this.isPremium = false,
    this.isLoading = true,
    this.priceText,
    this.error,
  });

  PremiumState copyWith({
    bool? isPremium,
    bool? isLoading,
    String? priceText,
    String? error,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      priceText: priceText ?? this.priceText,
      error: error,
    );
  }
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  final PurchaseService _purchaseService;
  static const String _premiumKey = 'is_premium';

  PremiumNotifier(this._purchaseService) : super(const PremiumState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // 購入完了コールバックを設定
    _purchaseService.onPurchaseComplete = _onPurchaseComplete;

    // ストアを初期化
    await _purchaseService.initialize();

    // ローカルの課金状態を読み込み
    await _loadPremiumStatus();

    // 価格情報を更新
    _updatePriceText();
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool(_premiumKey) ?? false;
    state = state.copyWith(isPremium: isPremium, isLoading: false);
  }

  void _updatePriceText() {
    final product = _purchaseService.product;
    if (product != null) {
      state = state.copyWith(priceText: product.price);
    }
  }

  void _onPurchaseComplete(bool success) async {
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumKey, true);
      state = state.copyWith(isPremium: true, isLoading: false, error: null);
    } else {
      state = state.copyWith(isLoading: false, error: '購入に失敗しました');
    }
  }

  /// 購入を実行
  Future<PurchaseResultType> purchase() async {
    if (!_purchaseService.isAvailable) {
      // ストアが利用不可（開発中など）はモック購入
      return _mockPurchase();
    }

    state = state.copyWith(isLoading: true, error: null);

    final started = await _purchaseService.purchase();

    if (!started) {
      state = state.copyWith(isLoading: false, error: '購入を開始できませんでした');
      return PurchaseResultType.error;
    }

    // 結果はコールバックで受け取る
    return PurchaseResultType.pending;
  }

  /// モック購入（開発用）
  Future<PurchaseResultType> _mockPurchase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, true);
    state = state.copyWith(isPremium: true, isLoading: false);
    return PurchaseResultType.success;
  }

  /// 購入を復元
  Future<void> restore() async {
    state = state.copyWith(isLoading: true, error: null);

    if (!_purchaseService.isAvailable) {
      state = state.copyWith(isLoading: false);
      return;
    }

    await _purchaseService.restore();

    // 結果はコールバックで受け取る
    // タイムアウト処理
    await Future.delayed(const Duration(seconds: 3));

    if (state.isLoading) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// デバッグ用：課金状態をリセット
  Future<void> debugReset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, false);
    state = state.copyWith(isPremium: false);
  }
}

/// 購入結果の種類
enum PurchaseResultType {
  success,
  pending, // 処理中（結果はコールバックで通知）
  cancelled,
  error,
}

/// PurchaseServiceのプロバイダー
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService.instance;
});

/// 課金状態のプロバイダー
final premiumProvider =
    StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  final purchaseService = ref.watch(purchaseServiceProvider);
  return PremiumNotifier(purchaseService);
});

/// 課金済みかどうかのショートカット
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(premiumProvider).isPremium;
});
