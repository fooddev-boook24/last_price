// lib/screens/item_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../providers/items_provider.dart';
import '../providers/premium_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/update_price_sheet.dart';
import '../analytics/app_analytics.dart';

class ItemDetailScreen extends ConsumerWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsState = ref.watch(itemsProvider);
    final isPremium = ref.watch(isPremiumProvider);

    final item = itemsState.items.where((i) => i.id == itemId).firstOrNull;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('商品が見つかりません'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('商品詳細'),
        actions: [
          // 削除ボタン
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, item),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品名
            Text(
              item.name,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeXLarge,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 32),

            // 現在価格
            _buildPriceSection(
              label: '現在価格',
              price: item.currentPrice,
              diff: item.priceDiff,
              isMain: true,
            ),
            const SizedBox(height: 24),

            // 前回価格
            if (item.previousPrice != null) ...[
              _buildPriceSection(
                label: '前回価格',
                price: item.previousPrice!,
                isMain: false,
              ),
              const SizedBox(height: 24),
            ],

            // 更新日時
            _buildInfoRow(
              label: '最終更新',
              value: _formatDate(item.updatedAt),
            ),

            // ピン留め（有料機能）
            const SizedBox(height: 32),
            _buildPinToggle(context, ref, item, isPremium),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => _showUpdatePriceSheet(context, item),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text(
              '価格を更新',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection({
    required String label,
    required int price,
    int? diff,
    required bool isMain,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeSmall,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '¥${_formatNumber(price)}',
              style: TextStyle(
                fontSize: isMain ? AppTheme.fontSizeXLarge : AppTheme.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            if (diff != null && isMain) ...[
              const SizedBox(width: 12),
              _buildDiffBadge(diff),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDiffBadge(int diff) {
    final color = diff > 0
        ? AppTheme.priceUp
        : diff < 0
            ? AppTheme.priceDown
            : AppTheme.priceSame;
    final prefix = diff > 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$prefix¥${_formatNumber(diff)}',
        style: TextStyle(
          fontSize: AppTheme.fontSizeSmall,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeSmall,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeSmall,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPinToggle(
    BuildContext context,
    WidgetRef ref,
    Item item,
    bool isPremium,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'ピン留め',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (!isPremium) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeXSmall,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '一覧の上部に固定表示',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeSmall,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          Switch(
            value: item.isPinned,
            onChanged: isPremium
                ? (value) async {
                    await ref
                        .read(itemsProvider.notifier)
                        .togglePin(item.id, isPremium: isPremium);
                  }
                : null,
            activeColor: AppTheme.textPrimary,
          ),
        ],
      ),
    );
  }

  void _showUpdatePriceSheet(BuildContext context, Item item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdatePriceSheet(item: item),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('商品を削除'),
        content: Text('「${item.name}」を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(itemsProvider.notifier).deleteItem(item.id);
              await AppAnalytics.itemDeleted();
              if (context.mounted) {
                Navigator.pop(context); // ダイアログを閉じる
                Navigator.pop(context); // 詳細画面を閉じる
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.priceUp,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.abs().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
