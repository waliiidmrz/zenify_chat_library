import 'dart:async';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:zenify_chat/store/mock_store.dart';
import 'package:zenify_chat/models/utils/model_extensions.dart';

/// 📦 Handles scroll-based pagination of chat history.
class ChatPaginationHandler {
  final ScrollController scrollController;
  final Timeline timeline;
  final ValueNotifier<List<Event>> messagesNotifier;
  final MockStoreService store;

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  bool hasReachedStart = false;

  final StreamController<void> _timelineUpdateController =
      StreamController<void>.broadcast();

  ValueNotifier<bool> get isLoadingNotifier => isLoading;

  ChatPaginationHandler({
    required this.scrollController,
    required this.timeline,
    required this.messagesNotifier,
    required this.store,
  }) {
    scrollController.addListener(_onScroll);
  }

  /// 📡 Called when the timeline updates from the SDK
  void Function() get onTimelineUpdate => () {
        _timelineUpdateController.add(null);
      };

  /// ⬆ Triggered when user scrolls to the top
  void _onScroll() {
    final offset = scrollController.offset;
    final triggerDistance = scrollController.position.maxScrollExtent - 150;

    if (!isLoading.value && !hasReachedStart && offset >= triggerDistance) {
      loadOlderMessages();
    }
  }

  /// 🔁 Loads older events from history
  Future<void> loadOlderMessages() async {
    if (hasReachedStart || isLoading.value) return;

    isLoading.value = true;
    final stopwatch = Stopwatch()..start();

    final beforeCount = timeline.events.length;

    await timeline.getRoomEvents(
      direction: Direction.b,
      historyCount: 15,
      filter: StateFilter(types: [EventTypes.Message]),
    );

    final afterCount = timeline.events.length;

    // ✅ Extract only the newly added events
    final newlyFetchedSlice = timeline.events.sublist(beforeCount, afterCount);

    final newlyFetched = _filterMessages(newlyFetchedSlice);
    if (newlyFetched.isEmpty) {
      print("✅ No new events: locking pagination");
      hasReachedStart = true;
    }

    final merged = _mergeEvents(messagesNotifier.value, newlyFetched);
    messagesNotifier.value = merged;

    // ✅ Update store to persist new full history
    final roomId = timeline.room.id;
    final roomInStore = store.getRoomById(roomId);

    if (roomInStore != null) {
      final updatedRoom =
          roomInStore.copyWith(events: List.from(merged.reversed));
      store.addOrUpdateRoom(updatedRoom);
    }

    final elapsed = stopwatch.elapsed;
    if (elapsed < const Duration(seconds: 1)) {
      await Future.delayed(Duration(seconds: 1) - elapsed);
    }

    isLoading.value = false;
  }

  List<Event> _filterMessages(List<Event> events) {
    return events
        .where((e) => e.type == EventTypes.Message && e.body.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => b.originServerTs.compareTo(a.originServerTs));
  }

  List<Event> _mergeEvents(List<Event> existing, List<Event> newOnes) {
    final all = [...existing, ...newOnes];

    // Deduplicate by eventId and transactionId
    final seen = <String>{};
    final deduped = <Event>[];

    for (final e in all) {
      final key = e.eventId;
      if (seen.contains(key)) continue;
      seen.add(key);
      deduped.add(e);
    }

    // Sort newest to oldest
    deduped.sort((a, b) => b.originServerTs.compareTo(a.originServerTs));
    return deduped;
  }

  void dispose() {
    scrollController.removeListener(_onScroll);
    _timelineUpdateController.close();
  }
}
