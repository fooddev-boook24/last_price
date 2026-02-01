// lib/widgets/banner_ad_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/ad_provider.dart';
import '../services/ad_service.dart';

/// バナー広告ウィジェット
/// 無料ユーザーにのみ表示される
class BannerAdWidget extends ConsumerWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShow = ref.watch(shouldShowAdProvider);
    final adService = ref.watch(adServiceProvider);

    if (!shouldShow || adService.bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: adService.bannerAd!.size.width.toDouble(),
      height: adService.bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: adService.bannerAd!),
    );
  }
}

/// 一覧画面の下部に表示するバナー広告コンテナ
class BannerAdContainer extends ConsumerWidget {
  const BannerAdContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShow = ref.watch(shouldShowAdProvider);

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.transparent,
      child: const SafeArea(
        top: false,
        child: BannerAdWidget(),
      ),
    );
  }
}
