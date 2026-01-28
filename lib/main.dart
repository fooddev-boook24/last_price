// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'first_open_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LAST PRICE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      home: const ItemListScreen(),
    );
  }
}

/// 起動直後に出る画面（0遷移）
/// Statefulは禁止なので ConsumerWidget で「読むだけ」実行。
class ItemListScreen extends ConsumerWidget {
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ★これが“初回だけ first_open を送る”トリガー（UIには一切出さない）
    ref.watch(firstOpenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LAST PRICE'),
        centerTitle: false,
      ),
      body: const Center(
        child: Text(
          '商品一覧（仮）',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
