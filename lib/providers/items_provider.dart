// lib/providers/items_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/item.dart';
import '../services/database_service.dart';
import '../analytics/app_analytics.dart';
import '../constants/app_constants.dart';

/// DatabaseServiceのプロバイダー
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// 商品一覧の状態
class ItemsState {
  final List<Item> items;
  final bool isLoading;
  final String? error;

  const ItemsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  ItemsState copyWith({
    List<Item>? items,
    bool? isLoading,
    String? error,
  }) {
    return ItemsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 商品一覧を管理するNotifier
class ItemsNotifier extends StateNotifier<ItemsState> {
  final DatabaseService _db;
  final Uuid _uuid = const Uuid();

  ItemsNotifier(this._db) : super(const ItemsState(isLoading: true)) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await _db.getAllItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// 商品を追加
  /// 無料プランの場合、制限を超えていたらfalseを返す
  Future<bool> addItem({
    required String name,
    required int price,
    required bool isPremium,
  }) async {
    // 無料プランの制限チェック
    if (!isPremium && state.items.length >= freeItemLimit) {
      return false;
    }

    try {
      final sortOrder = await _db.getNextSortOrder();
      final item = Item(
        id: _uuid.v4(),
        name: name,
        currentPrice: price,
        previousPrice: null,
        updatedAt: DateTime.now(),
        isPinned: false,
        sortOrder: sortOrder,
      );

      await _db.insertItem(item);
      await AppAnalytics.itemAdded();

      // 状態を更新
      state = state.copyWith(items: [...state.items, item]);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 価格を更新
  Future<void> updatePrice(String itemId, int newPrice) async {
    try {
      final index = state.items.indexWhere((item) => item.id == itemId);
      if (index == -1) return;

      final oldItem = state.items[index];
      final updatedItem = oldItem.updatePrice(newPrice);

      await _db.updateItem(updatedItem);
      await AppAnalytics.priceUpdated(
        priceDiff: updatedItem.priceDiff ?? 0,
      );

      // 状態を更新
      final newItems = [...state.items];
      newItems[index] = updatedItem;
      state = state.copyWith(items: newItems);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 商品名を更新
  Future<void> updateItemName(String itemId, String newName) async {
    try {
      final index = state.items.indexWhere((item) => item.id == itemId);
      if (index == -1) return;

      final oldItem = state.items[index];
      final updatedItem = oldItem.copyWith(name: newName);

      await _db.updateItem(updatedItem);

      final newItems = [...state.items];
      newItems[index] = updatedItem;
      state = state.copyWith(items: newItems);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// ピン留めを切り替え（有料機能）
  Future<bool> togglePin(String itemId, {required bool isPremium}) async {
    if (!isPremium) return false;

    try {
      final index = state.items.indexWhere((item) => item.id == itemId);
      if (index == -1) return false;

      final oldItem = state.items[index];
      final updatedItem = oldItem.copyWith(isPinned: !oldItem.isPinned);

      await _db.updateItem(updatedItem);

      // リストを再ソート
      final items = await _db.getAllItems();
      state = state.copyWith(items: items);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 商品を削除
  Future<void> deleteItem(String itemId) async {
    try {
      await _db.deleteItem(itemId);
      final newItems = state.items.where((item) => item.id != itemId).toList();
      state = state.copyWith(items: newItems);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// データをリロード
  Future<void> reload() async {
    state = state.copyWith(isLoading: true);
    await _loadItems();
  }
}

/// 商品一覧のプロバイダー
final itemsProvider = StateNotifierProvider<ItemsNotifier, ItemsState>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return ItemsNotifier(db);
});

/// 商品数のプロバイダー
final itemCountProvider = Provider<int>((ref) {
  return ref.watch(itemsProvider).items.length;
});
