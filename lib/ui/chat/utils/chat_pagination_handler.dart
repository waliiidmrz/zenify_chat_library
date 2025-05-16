import 'dart:async';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class ChatPaginationHandler {
  final ScrollController scrollController;
  final Timeline timeline;
  final ValueNotifier<List<Event>> messagesNotifier;

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  bool hasReachedStart = false;
  final StreamController<void> _timelineUpdateController =
      StreamController<void>.broadcast();
  ValueNotifier<bool> get isLoadingNotifier => isLoading;

  ChatPaginationHandler({
    required this.scrollController,
    required this.timeline,
    required this.messagesNotifier,
  }) {
    scrollController.addListener(_onScroll);
  }
  void Function() get onTimelineUpdate => () {
        _timelineUpdateController.add(null);
      };

  void _onScroll() {
    final offset = scrollController.offset;
    final triggerDistance = scrollController.position.maxScrollExtent - 150;

    if (!isLoading.value && !hasReachedStart && offset >= triggerDistance) {
      loadOlderMessages();
    }
  }

  Future<void> loadOlderMessages() async {
    if (hasReachedStart || isLoading.value) return;

    isLoading.value = true;
    final stopwatch = Stopwatch()..start();

    final before = timeline.events.length;

    await timeline.getRoomEvents(
      direction: Direction.b,
      historyCount: 15,
      filter: StateFilter(types: [EventTypes.Message]),
    );

    final after = timeline.events.length;
    final growth = after - before;

    if (growth == 0) {
      print("✅ No growth: locking further pagination");
      hasReachedStart = true;
    }

    final newlyFetched = timeline.events
        .where((e) => e.type == EventTypes.Message && e.body.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => b.originServerTs.compareTo(a.originServerTs));

    final existing = messagesNotifier.value;

    final merged = [
      ...existing,
      ...newlyFetched.where((e) => existing.every(
          (x) => x.eventId != e.eventId && x.transactionId != e.transactionId))
    ];

    messagesNotifier.value = merged;

    final elapsed = stopwatch.elapsed;
    if (elapsed < const Duration(seconds: 1)) {
      await Future.delayed(Duration(seconds: 1) - elapsed);
    }

    isLoading.value = false;
  }

  void dispose() {
    scrollController.removeListener(_onScroll);
  }
}
