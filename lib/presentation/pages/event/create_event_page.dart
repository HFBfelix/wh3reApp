import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wh3re/core/constants/app_colors.dart';
import 'package:wh3re/core/errors/repository_exception.dart';
import 'package:wh3re/repositories/repository_providers.dart';
import 'package:wh3re/presentation/widgets/auth_text_field.dart';
import 'package:wh3re/presentation/widgets/wh3re_primary_button.dart';

class CreateEventPage extends ConsumerStatefulWidget {
  const CreateEventPage({super.key});

  @override
  ConsumerState<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends ConsumerState<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ambianceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ambianceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final event = await ref.read(eventRepositoryProvider).createEvent(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            ambiance: _ambianceController.text.trim().isEmpty
                ? null
                : _ambianceController.text.trim(),
          );

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
        const SnackBar(content: Text('Impossible de créer l\'événement.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouvel événement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Donnez vie à votre sortie de groupe',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              AuthTextField(
                controller: _nameController,
                label: 'Nom de l\'événement',
                hint: 'Apéro d\'équipe',
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.event_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nom requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AuthTextField(
                controller: _descriptionController,
                label: 'Description (optionnel)',
                hint: 'Un vendredi soir entre collègues…',
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.notes_rounded,
              ),
              const SizedBox(height: 20),
              AuthTextField(
                controller: _ambianceController,
                label: 'Ambiance (optionnel)',
                hint: 'Cosy, festif, décontracté…',
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.mood_rounded,
              ),
              const SizedBox(height: 32),
              Wh3rePrimaryButton(
                label: 'Créer l\'événement',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
