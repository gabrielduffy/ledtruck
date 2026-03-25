import 'package:intl/intl.dart';

class DateFormatter {
  static final _date = DateFormat('dd/MM/yyyy');
  static final _time = DateFormat('HH:mm');
  static final _dateTime = DateFormat('dd/MM/yyyy HH:mm');

  static String date(DateTime dt) => _date.format(dt.toLocal());
  static String time(DateTime dt) => _time.format(dt.toLocal());
  static String dateTime(DateTime dt) => _dateTime.format(dt.toLocal());
  static String relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    return _date.format(dt.toLocal());
  }
}
