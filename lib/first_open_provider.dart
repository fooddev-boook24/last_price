// lib/first_open_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../analytics/app_analytics.dart';

/// これを watch した瞬間に、初回だけ first_open を送る（以後は何もしない）
final firstOpenProvider = FutureProvider<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();

  final alreadySent = prefs.getBool('first_open_sent') ?? false;
  if (alreadySent) return;

  await AppAnalytics.firstOpen();
  await prefs.setBool('first_open_sent', true);
});
