import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wh3re/models/question_model.dart';
import 'package:wh3re/models/response_model.dart';
import 'package:wh3re/repositories/repository_providers.dart';

/// Brouillon d'une réponse à une question.
class PollAnswerDraft {
  const PollAnswerDraft({
    this.selectedValue,
    this.weight = AnswerWeight.indifferent,
  });

  final String? selectedValue;
  final AnswerWeight weight;

  bool get isComplete => selectedValue != null && selectedValue!.isNotEmpty;

  PollAnswerDraft copyWith({
    String? selectedValue,
    AnswerWeight? weight,
  }) {
    return PollAnswerDraft(
      selectedValue: selectedValue ?? this.selectedValue,
      weight: weight ?? this.weight,
    );
  }
}

/// Questions du sondage pour un événement.
final eventQuestionsProvider =
    FutureProvider.family<List<QuestionModel>, String>((ref, eventId) {
  return ref.watch(eventRepositoryProvider).getQuestionsForEvent(eventId);
});

/// Statut de réponse de l'utilisateur courant sur un événement.
final memberResponseStatusProvider =
    FutureProvider.family<MemberResponseStatus, String>((ref, eventId) async {
  final repo = ref.watch(eventRepositoryProvider);
  final hasResponded = await repo.hasUserResponded(eventId);
  final response = await repo.getUserResponseForEvent(eventId);
  return MemberResponseStatus(
    hasResponded: hasResponded,
    response: response,
  );
});

class MemberResponseStatus {
  const MemberResponseStatus({
    required this.hasResponded,
    this.response,
  });

  final bool hasResponded;
  final ResponseModel? response;
}

/// Brouillon des réponses par `question_id`.
class PollDraftNotifier extends StateNotifier<Map<String, PollAnswerDraft>> {
  PollDraftNotifier() : super({});

  void initFromQuestions(List<QuestionModel> questions) {
    state = {
      for (final q in questions) q.id: const PollAnswerDraft(),
    };
  }

  void selectValue(String questionId, String value) {
    final current = state[questionId] ?? const PollAnswerDraft();
    state = {
      ...state,
      questionId: current.copyWith(selectedValue: value),
    };
  }

  void selectWeight(String questionId, AnswerWeight weight) {
    final current = state[questionId] ?? const PollAnswerDraft();
    state = {
      ...state,
      questionId: current.copyWith(weight: weight),
    };
  }

  bool get isComplete {
    if (state.isEmpty) return false;
    return state.values.every((draft) => draft.isComplete);
  }

  Map<String, AnswerEntry> toAnswerEntries() {
    return state.map(
      (questionId, draft) => MapEntry(
        questionId,
        AnswerEntry(
          value: draft.selectedValue!,
          weight: draft.weight,
        ),
      ),
    );
  }
}

final pollDraftProvider = StateNotifierProvider.autoDispose
    .family<PollDraftNotifier, Map<String, PollAnswerDraft>, String>(
  (ref, eventId) => PollDraftNotifier(),
);

/// Soumission du sondage.
final pollSubmitProvider =
    StateNotifierProvider.autoDispose.family<PollSubmitNotifier, AsyncValue<void>, String>(
  (ref, eventId) => PollSubmitNotifier(ref, eventId),
);

class PollSubmitNotifier extends StateNotifier<AsyncValue<void>> {
  PollSubmitNotifier(this._ref, this._eventId) : super(const AsyncData(null));

  final Ref _ref;
  final String _eventId;

  Future<bool> submit(Map<String, AnswerEntry> answers) async {
    state = const AsyncLoading();
    try {
      await _ref.read(eventRepositoryProvider).submitResponse(
            eventId: _eventId,
            answers: answers,
          );
      state = const AsyncData(null);
      _ref.invalidate(memberResponseStatusProvider(_eventId));
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
