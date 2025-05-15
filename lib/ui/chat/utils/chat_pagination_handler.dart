import 'dart:async';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class ChatPaginationHandler {
  final ScrollController scrollController;
  final Timeline timeline;
  final ValueNotifier<List<Event>> messagesNotifier;

  bool isLoading = false;
  bool hasReachedStart = false;
  final StreamController<void> _timelineUpdateController =
      StreamController<void>.broadcast();

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

    if (!isLoading && !hasReachedStart && offset >= triggerDistance) {
      loadOlderMessages();
    }
  }

  Future<void> loadOlderMessages() async {
    if (hasReachedStart || isLoading) return;

    isLoading = true;
    final before = timeline.events.length;

    // Start fetch
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
      ..sort((a, b) =>
          b.originServerTs.compareTo(a.originServerTs)); // newest to oldest

    final existing = messagesNotifier.value;

    // Prepend older messages
    final merged = [
      ...existing,
      ...newlyFetched.where((e) => existing.every(
          (x) => x.eventId != e.eventId && x.transactionId != e.transactionId))
    ];

    messagesNotifier.value = merged;
    print("🧭 Newly fetched (descending):");
    for (final e in newlyFetched) {
      print("- ${e.body} | ts=${e.originServerTs}");
    }

    print("🧭 Existing before merge:");
    for (final e in existing) {
      print("- ${e.body} | ts=${e.originServerTs}");
    }

    print("🧾  Final rendered (descending):");
    for (final e in merged) {
      print("- ${e.body} | ts=${e.originServerTs}");
    }

    isLoading = false;
  }

  void dispose() {
    scrollController.removeListener(_onScroll);
  }
}
