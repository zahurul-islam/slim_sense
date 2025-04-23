import 'package:intl/intl.dart';

class AppDateUtils {
  // Format date as "Jan 15, 2025"
  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  // Format date as "Monday, January 15"
  static String formatDateWithDay(DateTime date) {
    return DateFormat.MMMMEEEEd().format(date);
  }

  // Format date as "15 Jan"
  static String formatShortDate(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  // Format date as "Jan"
  static String formatMonth(DateTime date) {
    return DateFormat.MMM().format(date);
  }

  // Format date as "15"
  static String formatDay(DateTime date) {
    return DateFormat.d().format(date);
  }

  // Format time as "13:45"
  static String formatTime(DateTime date) {
    return DateFormat.Hm().format(date);
  }

  // Format time as "1:45 PM"
  static String formatTime12Hour(DateTime date) {
    return DateFormat.jm().format(date);
  }

  // Format date and time as "Jan 15, 2025, 1:45 PM"
  static String formatDateTime(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  // Get start of the day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of the day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  // Get start of the week (Monday as first day)
  static DateTime startOfWeek(DateTime date) {
    int difference = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: difference)));
  }

  // Get end of the week (Sunday as last day)
  static DateTime endOfWeek(DateTime date) {
    int difference = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: difference)));
  }

  // Get start of the month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of the month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  // Get start of the year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  // Get end of the year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59);
  }

  // Get list of days in a date range
  static List<DateTime> getDaysInRange(DateTime start, DateTime end) {
    final List<DateTime> days = [];
    DateTime current = startOfDay(start);
    
    while (current.isBefore(endOfDay(end)) || current.isAtSameMomentAs(startOfDay(end))) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return days;
  }

  // Get list of months in a date range
  static List<DateTime> getMonthsInRange(DateTime start, DateTime end) {
    final List<DateTime> months = [];
    DateTime current = startOfMonth(start);
    
    while (current.isBefore(endOfMonth(end)) || current.year == end.year && current.month == end.month) {
      months.add(current);
      current = DateTime(current.year, current.month + 1, 1);
    }
    
    return months;
  }

  // Get age from birth date
  static int calculateAge(DateTime birthDate) {
    final DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  // Check if a date is today
  static bool isToday(DateTime date) {
    final DateTime now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  // Check if a date is tomorrow
  static bool isTomorrow(DateTime date) {
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  // Get relative date description like "Today", "Yesterday", "Tomorrow", or the formatted date
  static String getRelativeDateDescription(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else {
      return formatDate(date);
    }
  }

  // Get week number in the year (ISO-8601 standard, weeks starting on Monday)
  static int getWeekNumber(DateTime date) {
    final DateTime januaryFirst = DateTime(date.year, 1, 1);
    final int daysOffset = januaryFirst.weekday - 1;
    final DateTime firstMonday = januaryFirst.add(Duration(days: daysOffset > 0 ? 7 - daysOffset : 0));
    
    if (date.isBefore(firstMonday)) {
      return getWeekNumber(date.subtract(const Duration(days: 7)));
    }
    
    final int daysSinceFirstMonday = date.difference(firstMonday).inDays;
    return 1 + (daysSinceFirstMonday / 7).floor();
  }
}
