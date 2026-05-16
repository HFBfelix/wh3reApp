import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wh3re/core/constants/app_colors.dart';
import 'package:wh3re/core/utils/haptics.dart';
import 'package:wh3re/core/errors/repository_exception.dart';
import 'package:wh3re/models/question_model.dart';
import 'package:wh3re/models/response_model.dart';
import 'package:wh3re/providers/poll_provider.dart';
import 'package:wh3re/presentation/widgets/shimmer_loader.dart';
import 'package:wh3re/presentation/widgets/weight_selector.dart';
import 'package:wh3re/presentation/widgets/wh3re_primary_button.dart';

/// Interface de vote invité — cartes par question + pondération.
class PollPage extends ConsumerStatefulWidget {
  const PollPage({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<PollPage> createState() => _PollPageState();
}

class _PollPageState extends ConsumerState<PollPage> {
  bool _showSuccess = false;

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return _PollSuccessOverlay(
        onDone: () => context.go('/events/${widget.eventId}'),
      );
    }

    final questionsAsync = ref.watch(eventQuestionsProvider(widget.eventId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Votre avis compte'),
      ),
      body: questionsAsync.when(
        loading: () => const ShimmerLoader(itemCount: 4),
        error: (error, _) => _PollError(
          message: error is RepositoryException
              ? error.message
              : 'Impossible de charger le sondage.',
          onRetry: () =>
              ref.invalidate(eventQuestionsProvider(widget.eventId)),
        ),
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(
              child: Text('Aucune question configurée pour cet événement.'),
            );
          }
          return _PollForm(
            eventId: widget.eventId,
            questions: questions,
            onSubmitted: () => setState(() => _showSuccess = true),
          );
        },
      ),
    );
  }
}

class _PollForm extends ConsumerStatefulWidget {
  const _PollForm({
    required this.eventId,
    required this.questions,
    required this.onSubmitted,
  });

  final String eventId;
  final List<QuestionModel> questions;
  final VoidCallback onSubmitted;

  @override
  ConsumerState<_PollForm> createState() => _PollFormState();
}

class _PollFormState extends ConsumerState<_PollForm> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(pollDraftProvider(widget.eventId));
    final submitState = ref.watch(pollSubmitProvider(widget.eventId));
    final isSubmitting = submitState.isLoading;

    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(pollDraftProvider(widget.eventId).notifier)
            .initFromQuestions(widget.questions);
      });
    }

    final notifier = ref.read(pollDraftProvider(widget.eventId).notifier);
    final canSubmit = notifier.isComplete && !isSubmitting;

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: widget.questions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final question = widget.questions[index];
              final answerDraft = draft[question.id] ?? const PollAnswerDraft();

              return _QuestionCard(
                question: question,
                draft: answerDraft,
                onValueSelected: (value) =>
                    notifier.selectValue(question.id, value),
                onWeightChanged: (weight) =>
                    notifier.selectWeight(question.id, weight),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wh3rePrimaryButton(
            label: 'Envoyer mes réponses',
            isLoading: isSubmitting,
            onPressed: canSubmit ? () => _submit(notifier) : null,
          ),
        ),
      ],
    );
  }

  Future<void> _submit(PollDraftNotifier notifier) async {
    final success = await ref
        .read(pollSubmitProvider(widget.eventId).notifier)
        .submit(notifier.toAnswerEntries());

    if (!mounted) return;

    if (success) {
      widget.onSubmitted();
    } else {
      final error = ref.read(pollSubmitProvider(widget.eventId)).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is RepositoryException
                ? error.message
                : 'Échec de l\'envoi. Réessayez.',
          ),
        ),
      );
    }
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.draft,
    required this.onValueSelected,
    required this.onWeightChanged,
  });

  final QuestionModel question;
  final PollAnswerDraft draft;
  final ValueChanged<String> onValueSelected;
  final ValueChanged<AnswerWeight> onWeightChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.questionLabel,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: question.options.map((option) {
              final isSelected = draft.selectedValue == option.value;
              return FilterChip(
                label: Text(
                  '${option.emoji ?? ''} ${option.label}'.trim(),
                ),
                selected: isSelected,
                onSelected: (_) async {
                  await Wh3reHaptics.selectionClick();
                  onValueSelected(option.value);
                },
                selectedColor: AppColors.primarySurface,
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Importance pour vous',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          WeightSelector(
            selected: draft.weight,
            onChanged: onWeightChanged,
          ),
        ],
      ),
    );
  }
}

class _PollSuccessOverlay extends StatefulWidget {
  const _PollSuccessOverlay({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_PollSuccessOverlay> createState() => _PollSuccessOverlayState();
}

class _PollSuccessOverlayState extends State<_PollSuccessOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 56,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Merci !',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vos préférences ont été enregistrées.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PollError extends StatelessWidget {
  const _PollError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
