// lib/screens/item_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/items_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/ad_provider.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../widgets/item_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/banner_ad_widget.dart';
import 'settings_screen.dart';

class ItemListScreen extends ConsumerStatefulWidget {
  const ItemListScreen({super.key});

  @override
  ConsumerState<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends ConsumerState<ItemListScreen> {
  @override
  void initState() {
    super.initState();
    // 広告を初期化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemsState = ref.watch(itemsProvider);
    final premiumState = ref.watch(premiumProvider);
    final itemCount = ref.watch(itemCountProvider);
    final shouldShowAd = ref.watch(shouldShowAdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LAST PRICE'),
        centerTitle: false,
        actions: [
          // 設定ボタン
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(itemsState, premiumState),
      floatingActionButton: _buildFab(itemCount, premiumState),
      // 広告を下部に固定表示
      bottomNavigationBar: shouldShowAd ? const BannerAdContainer() : null,
    );
  }

  Widget _buildBody(ItemsState itemsState, PremiumState premiumState) {
    if (itemsState.isLoading || premiumState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppTheme.textPrimary,
        ),
      );
    }

    if (itemsState.items.isEmpty) {
      return const EmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: itemsState.items.length,
      itemBuilder: (context, index) {
        final item = itemsState.items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ItemCard(item: item),
        );
      },
    );
  }

  Widget? _buildFab(int itemCount, PremiumState premiumState) {
    // ローディング中はFABを表示しない
    if (premiumState.isLoading) return null;

    final canAdd = premiumState.isPremium || itemCount < freeItemLimit;

    return FloatingActionButton.extended(
      onPressed: () => _showAddItemSheet(canAdd),
      icon: const Icon(Icons.add),
      label: Text(
        canAdd ? '商品を追加' : '上限に達しました',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  void _showAddItemSheet(bool canAdd) {
    if (!canAdd) {
      // 無料上限に達している場合は課金促進
      _showUpgradeDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddItemSheet(),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('商品数の上限'),
        content: const Text(
          '無料版では$freeItemLimit件まで登録できます。\n\n'
          'プレミアム版にアップグレードすると、無制限に商品を登録できます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            child: const Text('アップグレード'),
          ),
        ],
      ),
    );
  }
}
