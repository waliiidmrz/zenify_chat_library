import 'package:matrix/matrix.dart';

/// 🔁 Checks if event A is more recent than B based on Matrix event status
bool isMoreRecent(Event a, Event b) {
  return a.status.index > b.status.index;
}

/// 📦 Merges and sorts two sets of events while deduplicating
List<Event> mergeAndSortEvents(List<Event> oldEvents, List<Event> newEvents) {
  final Map<String, Event> byEventId = {
    for (var e in oldEvents.where((e) => e.eventId != null)) e.eventId: e,
  };
  final Map<String, Event> byTxnId = {
    for (var e in oldEvents.where((e) => e.transactionId != null))
      e.transactionId!: e,
  };

  final List<Event> merged = [];

  for (final e in newEvents) {
    final existing = byEventId.containsKey(e.eventId)
        ? byEventId[e.eventId]
        : (e.transactionId != null && byTxnId.containsKey(e.transactionId)
            ? byTxnId[e.transactionId]
            : null);

    if (existing == null || isMoreRecent(e, existing)) {
      merged.add(e);
    } else {
      merged.add(existing);
    }
  }

  final existingIds = {
    ...merged.map((e) => e.eventId),
    ...merged.map((e) => e.transactionId),
  }.whereType<String>().toSet();

  for (final e in oldEvents) {
    if (!existingIds.contains(e.eventId) &&
        !existingIds.contains(e.transactionId)) {
      merged.add(e);
    }
  }

  merged.sort((a, b) => a.originServerTs.compareTo(b.originServerTs));
  return merged;
}
