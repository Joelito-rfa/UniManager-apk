import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class DateFormatter {
  static final DateFormat _displayDate = DateFormat(AppConstants.dateFormatDisplay);
  static final DateFormat _apiDate = DateFormat(AppConstants.dateFormatApi);
  static final DateFormat _displayDateTime = DateFormat(AppConstants.dateTimeFormatDisplay);
  static final DateFormat _displayTime = DateFormat(AppConstants.timeFormatDisplay);

  static String toDisplayDate(DateTime? date) {
    if (date == null) return '';
    return _displayDate.format(date);
  }

  static String toApiDate(DateTime? date) {
    if (date == null) return '';
    return _apiDate.format(date);
  }

  static String toDisplayDateTime(DateTime? date) {
    if (date == null) return '';
    return _displayDateTime.format(date);
  }

  static String toDisplayTime(DateTime? date) {
    if (date == null) return '';
    return _displayTime.format(date);
  }

  static DateTime? fromApiDate(String? date) {
    if (date == null || date.isEmpty) return null;
    try {
      return _apiDate.parse(date);
    } catch (_) {
      return null;
    }
  }

  static DateTime? fromDisplayDate(String? date) {
    if (date == null || date.isEmpty) return null;
    try {
      return _displayDate.parse(date);
    } catch (_) {
      return null;
    }
  }

  static String formatRelative(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    if (diff.inDays < 30) return 'Il y a ${diff.inDays ~/ 7} semaines';
    return toDisplayDate(date);
  }

  static String monthYear(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMMM yyyy', 'fr').format(date);
  }

  static String dayName(DateTime? date) {
    if (date == null) return '';
    return DateFormat('EEEE', 'fr').format(date);
  }

  static List<DateTime> getWeekDays(DateTime weekStart) {
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  static DateTime getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String timeRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '';
    return '${toDisplayTime(start)} - ${toDisplayTime(end)}';
  }
}
