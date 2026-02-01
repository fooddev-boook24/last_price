// lib/services/purchase_service.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// 課金設定
class PurchaseConfig {
  // プロダクトID（App Store Connect / Google Play Console で設定したID）
  static const String premiumProductId = 'last_price_premium';
}

/// 課金サービス
class PurchaseService {
  static PurchaseService? _instance;
  static PurchaseService get instance => _instance ??= PurchaseService._();

  PurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  ProductDetails? _product;

  /// ストアが利用可能か
  bool get isAvailable => _isAvailable;

  /// プロダクト情報
  ProductDetails? get product => _product;

  /// 購入完了時のコールバック
  Function(bool success)? onPurchaseComplete;

  /// 初期化
  Future<void> initialize() async {
    print('[IAP] Initializing...');
    _isAvailable = await _iap.isAvailable();
    print('[IAP] Store available: $_isAvailable');

    if (!_isAvailable) {
      print('[IAP] In-app purchase not available');
      return;
    }

    // 購入ストリームを監視
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) {
        print('[IAP] Purchase stream error: $error');
      },
    );

    // プロダクト情報を取得
    await _loadProducts();

    print('[IAP] Initialization complete');
  }

  /// プロダクト情報を読み込み
  Future<void> _loadProducts() async {
    print('[IAP] Loading product: ${PurchaseConfig.premiumProductId}');

    final response = await _iap.queryProductDetails({
      PurchaseConfig.premiumProductId,
    });

    print('[IAP] Query response received');

    if (response.error != null) {
      print('[IAP] Product query error: ${response.error}');
      return;
    }

    if (response.notFoundIDs.isNotEmpty) {
      print('[IAP] Products not found: ${response.notFoundIDs}');
    }

    if (response.productDetails.isEmpty) {
      print('[IAP] No products returned from store');
      return;
    }

    _product = response.productDetails.first;
    print('[IAP] Product loaded: ${_product!.title} - ${_product!.price}');
  }

  /// 購入を実行
  Future<bool> purchase() async {
    print('[IAP] Purchase called');
    print('[IAP] isAvailable: $_isAvailable');
    print('[IAP] product: $_product');

    if (!_isAvailable) {
      print('[IAP] Store not available');
      return false;
    }

    if (_product == null) {
      print('[IAP] Product is null - cannot purchase');
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: _product!);

    try {
      print('[IAP] Starting buyNonConsumable...');
      final result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      print('[IAP] buyNonConsumable result: $result');
      return result;
    } catch (e) {
      print('[IAP] Purchase error: $e');
      return false;
    }
  }

  /// 購入を復元
  Future<void> restore() async {
    if (!_isAvailable) return;
    await _iap.restorePurchases();
  }

  /// 購入更新を処理
  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _handlePurchase(purchase);
    }
  }

  /// 個別の購入を処理
  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.pending) {
      // 処理中
      if (kDebugMode) {
        print('Purchase pending: ${purchase.productID}');
      }
    } else if (purchase.status == PurchaseStatus.error) {
      // エラー
      if (kDebugMode) {
        print('Purchase error: ${purchase.error}');
      }
      onPurchaseComplete?.call(false);
    } else if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      // 購入完了 or 復元完了
      if (kDebugMode) {
        print('Purchase success: ${purchase.productID}');
      }

      // 購入を確定（これを呼ばないとストアに保留される）
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }

      onPurchaseComplete?.call(true);
    } else if (purchase.status == PurchaseStatus.canceled) {
      // キャンセル
      if (kDebugMode) {
        print('Purchase canceled');
      }
    }
  }

  /// 破棄
  void dispose() {
    _subscription?.cancel();
  }
}
