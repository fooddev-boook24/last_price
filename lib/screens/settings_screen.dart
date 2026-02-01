// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/premium_provider.dart';
import '../providers/items_provider.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../analytics/app_analytics.dart';
import '../services/appsflyer_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(premiumProvider);
    final itemCount = ref.watch(itemCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // プレミアムセクション
          _buildPremiumCard(context, ref, premiumState, itemCount),

          const SizedBox(height: 24),

          // アプリ情報
          _buildSectionTitle('アプリ情報'),
          _buildInfoTile(
            icon: Icons.info_outline,
            title: 'バージョン',
            trailing: const Text('1.0.0'),
          ),

          // デバッグ用（本番では削除）
          if (premiumState.isPremium) ...[
            const SizedBox(height: 24),
            _buildSectionTitle('デバッグ'),
            _buildActionTile(
              icon: Icons.refresh,
              title: '課金状態をリセット',
              onTap: () async {
                await ref.read(premiumProvider.notifier).debugReset();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('課金状態をリセットしました')),
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPremiumCard(
    BuildContext context,
    WidgetRef ref,
    PremiumState premiumState,
    int itemCount,
  ) {
    if (premiumState.isPremium) {
      return _buildActivePremiumCard();
    }

    final priceText = premiumState.priceText ?? '¥480';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.textPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'LAST PRICE Pro',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '無制限に商品を登録できます',
            style: TextStyle(
              fontSize: AppTheme.fontSizeMedium,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          // 現在の使用状況
          Row(
            children: [
              Text(
                '現在の登録数: $itemCount / $freeItemLimit',
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeSmall,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: itemCount / freeItemLimit,
                    backgroundColor: AppTheme.divider,
                    color: itemCount >= freeItemLimit
                        ? AppTheme.priceUp
                        : AppTheme.textPrimary,
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 機能一覧
          _buildFeatureItem('商品登録数：無制限'),
          const SizedBox(height: 8),
          _buildFeatureItem('ピン留め機能'),
          const SizedBox(height: 8),
          _buildFeatureItem('広告非表示'),
          const SizedBox(height: 20),
          // 購入ボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: premiumState.isLoading
                  ? null
                  : () => _purchase(context, ref),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: premiumState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '$priceText で購入（買い切り）',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          // リストアボタン
          Center(
            child: TextButton(
              onPressed: premiumState.isLoading
                  ? null
                  : () => _restore(context, ref),
              child: const Text(
                '購入を復元',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeSmall,
                ),
              ),
            ),
          ),
          // エラー表示
          if (premiumState.error != null) ...[
            const SizedBox(height: 12),
            Text(
              premiumState.error!,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeSmall,
                color: AppTheme.priceUp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivePremiumCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.priceDown, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.priceDown.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppTheme.priceDown,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LAST PRICE Pro',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '有効',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeSmall,
                  color: AppTheme.priceDown,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check,
          size: 18,
          color: AppTheme.priceDown,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeSmall,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: AppTheme.fontSizeSmall,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase(BuildContext context, WidgetRef ref) async {
    await AppAnalytics.paywallShown();

    final result = await ref.read(premiumProvider.notifier).purchase();

    if (result == PurchaseResultType.success) {
      await AppAnalytics.purchaseCompleted();
      await AppsFlyerService.instance.logPurchase(
        productId: 'last_price_premium',
        price: 480,
        currency: 'JPY',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('購入が完了しました')),
        );
      }
    }
    // pending/errorはコールバック経由で処理されるか、stateのerrorで表示
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    await ref.read(premiumProvider.notifier).restore();

    if (context.mounted) {
      final isPremium = ref.read(isPremiumProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPremium ? '購入を復元しました' : '復元する購入が見つかりませんでした',
          ),
        ),
      );
    }
  }
}
