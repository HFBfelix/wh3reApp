import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wh3re/app/router.dart';
import 'package:wh3re/core/constants/app_colors.dart';
/// Racine de l'application Wh3re : [MaterialApp.router] + [GoRouter] + thème.
class Wh3reApp extends ConsumerWidget {
  const Wh3reApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Wh3re',
      debugShowCheckedModeBanner: false,
      theme: AppColors.theme,
      routerConfig: router,
    );
  }
}
