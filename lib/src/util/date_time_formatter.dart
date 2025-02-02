import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

class DateTimeFormatter {
  static String format(String? dateString, {bool showElapsedTime = true}) {
    if (dateString == null || dateString.isEmpty) {
      return 'Date not available';
    }

    try {
      final dateTime = DateTime.parse(dateString);
      final locale = Intl.getCurrentLocale();
      final hasTime = _hasTimeComponent(dateString);
      final now = DateTime.now();

      // Format the main date/time string
      String mainDateTime;
      if (!hasTime) {
        if (_isToday(dateTime)) {
          mainDateTime = 'Today';
        } else if (_isYesterday(dateTime)) {
          mainDateTime = 'Yesterday';
        } else if (_isThisYear(dateTime)) {
          mainDateTime = DateFormat.MMMd(locale).format(dateTime);
        } else {
          mainDateTime = DateFormat.yMMMd(locale).format(dateTime);
        }
      } else {
        final timeStr = DateFormat.jm(locale).format(dateTime);

        if (_isToday(dateTime)) {
          mainDateTime = 'Today at $timeStr';
        } else if (_isYesterday(dateTime)) {
          mainDateTime = 'Yesterday at $timeStr';
        } else if (_isThisYear(dateTime)) {
          final dateStr = DateFormat.MMMd(locale).format(dateTime);
          mainDateTime = '$dateStr at $timeStr';
        } else {
          final dateStr = DateFormat.yMMMd(locale).format(dateTime);
          mainDateTime = '$dateStr at $timeStr';
        }
      }
      // Calculate elapsed time if needed
      if (showElapsedTime && dateTime.isBefore(now)) {
        final elapsed = _formatElapsedTime(dateTime, now);
        return '$mainDateTime\n$elapsed';
      }

      return mainDateTime;
    } catch (e) {
      return dateString;
    }
  }

  static String _formatElapsedTime(DateTime dateTime, DateTime now) {
    final difference = now.difference(dateTime);

    final years = difference.inDays ~/ 365;
    final months = difference.inDays ~/ 30;
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    final List<String> parts = [];

    if (years > 0) {
      parts.add('${years} ${_pluralize('year', years)}');
    }
    if (months > 0 && years == 0) {
      parts.add('${months} ${_pluralize('month', months)}');
    }
    if (days > 0 && years == 0 && months == 0) {
      parts.add('${days} ${_pluralize('day', days)}');
    }
    if (hours > 0 && days == 0) {
      parts.add('${hours} ${_pluralize('hour', hours)}');
    }
    if (minutes > 0 && days == 0 && hours == 0) {
      parts.add('${minutes} ${_pluralize('minute', minutes)}');
    }
    if (parts.isEmpty) {
      parts.add('just now');
    }

    return '${parts.join(', ')} ago';
  }

  static String _pluralize(String word, int count) {
    return count == 1 ? word : '${word}s';
  }

  static bool _hasTimeComponent(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return dateTime.hour != 0 ||
          dateTime.minute != 0 ||
          dateTime.second != 0 ||
          dateString.contains('T') ||
          dateString.contains(' ');
    } catch (e) {
      return false;
    }
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool _isThisYear(DateTime date) {
    return date.year == DateTime.now().year;
  }
}

class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}
