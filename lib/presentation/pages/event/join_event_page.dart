import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wh3re/core/constants/app_colors.dart';
import 'package:wh3re/core/errors/repository_exception.dart';
import 'package:wh3re/repositories/repository_providers.dart';

/// Rejoint un événement via deep link `/join/:token` puis redirige vers le détail.
class JoinEventPage extends ConsumerStatefulWidget {
  const JoinEventPage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<JoinEventPage> createState() => _JoinEventPageState();
}

class _JoinEventPageState extends ConsumerState<JoinEventPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _join());
  }

  Future<void> _join() async {
    try {
      final event = await ref
          .read(eventRepositoryProvider)
          .joinEventByToken(widget.token);
      if (!mounted) return;
      context.go('/events/${event.id}');
    } on RepositoryException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } on Object catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de rejoindre cet événement.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Connexion à l\'événement…',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
