import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wh3re/models/event_model.dart';
import 'package:wh3re/models/suggestion_model.dart';
import 'package:wh3re/repositories/repository_providers.dart';

final eventSuggestionsProvider =
    FutureProvider.family<List<SuggestionModel>, String>((ref, eventId) {
  return ref.watch(eventRepositoryProvider).getSuggestionsForEvent(eventId);
});

final isEventCreatorProvider = FutureProvider.family<bool, String>((ref, eventId) {
  return ref.watch(eventRepositoryProvider).isCurrentUserCreator(eventId);
});

final selectPlaceControllerProvider = StateNotifierProvider.autoDispose
    .family<SelectPlaceController, AsyncValue<void>, String>((ref, eventId) {
  return SelectPlaceController(ref, eventId);
});

class SelectPlaceController extends StateNotifier<AsyncValue<void>> {
  SelectPlaceController(this._ref, this._eventId) : super(const AsyncData(null));

  final Ref _ref;
  final String _eventId;

  Future<EventModel?> selectPlace(SuggestionModel suggestion) async {
    state = const AsyncLoading();
    EventModel? event;
    state = await AsyncValue.guard(() async {
      event = await _ref.read(eventRepositoryProvider).selectFinalPlace(
            eventId: _eventId,
            suggestion: suggestion,
          );
    });
    if (state.hasError) return null;
    _ref.invalidate(eventSuggestionsProvider(_eventId));
    return event;
  }
}
