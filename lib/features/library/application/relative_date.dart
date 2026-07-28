/// Pure date-formatting helpers for the Library preview. Every caller passes
/// an explicit `now` (always [libraryPreviewNow] in this milestone) rather
/// than reading `DateTime.now()`, so grouping and relative-date copy stay
/// deterministic in tests regardless of when they run.
library;

/// Groups a saved date into one of the Library list's section headers.
String dateGroupLabel(DateTime savedAt, DateTime now) {
  final startOfToday = DateTime(now.year, now.month, now.day);
  final startOfSavedDay = DateTime(savedAt.year, savedAt.month, savedAt.day);
  final dayDiff = startOfToday.difference(startOfSavedDay).inDays;

  if (dayDiff <= 0) return 'Today';
  if (dayDiff == 1) return 'Yesterday';
  if (dayDiff <= 7) return 'This week';
  return 'Earlier';
}

/// Short, honest relative-date copy for list subtitles and the duplicate
/// scan sheet, e.g. "Today", "Yesterday", "3 days ago", or a plain date once
/// the item is old enough that a relative phrase stops being useful.
String formatRelativeDate(DateTime savedAt, DateTime now) {
  final startOfToday = DateTime(now.year, now.month, now.day);
  final startOfSavedDay = DateTime(savedAt.year, savedAt.month, savedAt.day);
  final dayDiff = startOfToday.difference(startOfSavedDay).inDays;

  if (dayDiff <= 0) return 'Today';
  if (dayDiff == 1) return 'Yesterday';
  if (dayDiff < 7) return '$dayDiff days ago';
  return formatPlainDate(savedAt);
}

/// A short, unambiguous absolute date, e.g. "Jul 20, 2026".
String formatPlainDate(DateTime date) {
  const months = [
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
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
