class AppDateUtils {
  AppDateUtils._();

  static String formatAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return '$age ans';
  }

  static String formatDuration(DateTime start, DateTime end) {
    final diff = end.difference(start);
    final days = diff.inDays;
    if (days < 1) return '${diff.inHours}h';
    return '${days}j';
  }
}