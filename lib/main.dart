import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wh3re/app/app.dart';
import 'package:wh3re/core/supabase_client.dart';
import 'package:wh3re/providers/deep_link_provider.dart';
import 'package:wh3re/services/deep_link_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    throw StateError(
      'Variables SUPABASE_URL et SUPABASE_ANON_KEY requises dans .env',
    );
  }

  await SupabaseClientManager.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final deepLinkService = DeepLinkService();
  await deepLinkService.init();

  runApp(
    ProviderScope(
      overrides: [
        deepLinkServiceProvider.overrideWithValue(deepLinkService),
      ],
      child: const Wh3reApp(),
    ),
  );
}
