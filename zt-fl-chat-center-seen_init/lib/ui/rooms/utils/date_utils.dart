import 'package:intl/intl.dart';

String formatRoomDate(DateTime? date) {
  if (date == null) return '';
  final now = DateTime.now();

  final isToday =
      date.year == now.year && date.month == now.month && date.day == now.day;

  return isToday
      ? DateFormat.Hm().format(date)
      : DateFormat('dd MMM').format(date);
}
