class TimeUtils {
  const TimeUtils._();

  static bool isToday(DateTime date, DateTime today) {
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  static bool isYesterday(DateTime date, DateTime yesterday, DateTime today) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly == yesterday;
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]}';
    }
  }
}
