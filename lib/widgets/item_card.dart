// lib/widgets/item_card.dart
import 'package:flutter/material.dart';
import '../models/item.dart';
import '../constants/app_theme.dart';
import '../screens/item_detail_screen.dart';

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailScreen(itemId: item.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            // ピン留めアイコン
            if (item.isPinned)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.push_pin,
                  size: 16,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
              ),

            // 商品名と前回価格
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.previousPrice != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '前回 ¥${_formatNumber(item.previousPrice!)}',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeSmall,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 16),

            // 現在価格と差分
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '¥${_formatNumber(item.currentPrice)}',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (item.priceDiff != null) ...[
                  const SizedBox(height: 4),
                  _buildDiffBadge(item.priceDiff!),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiffBadge(int diff) {
    if (diff == 0) {
      return const Text(
        '±0',
        style: TextStyle(
          fontSize: AppTheme.fontSizeSmall,
          color: AppTheme.priceSame,
        ),
      );
    }

    final isUp = diff > 0;
    final color = isUp ? AppTheme.priceUp : AppTheme.priceDown;
    final prefix = isUp ? '+' : '';
    final icon = isUp ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            '$prefix¥${_formatNumber(diff)}',
            style: TextStyle(
              fontSize: AppTheme.fontSizeSmall,
              fontWeight: FontWeight.w600,
              color: color,
            ),
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
}
