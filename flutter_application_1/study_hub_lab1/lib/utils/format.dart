/// R8: own formatting, no packages. "18 Oct, 10:00"
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String formatHm(int hour, int minute) => '${_two(hour)}:${_two(minute)}';

String formatTime(DateTime d) => formatHm(d.hour, d.minute);

String formatDateTime(DateTime d) => '${formatDate(d)}, ${formatTime(d)}';

String formatDuration(Duration d) {
  if (d.inDays > 0) {
    return '${d.inDays}d ${d.inHours % 24}h';
  }
  if (d.inHours > 0) {
    return '${d.inHours}h ${d.inMinutes % 60}m';
  }
  return '${d.inMinutes}m';
}
