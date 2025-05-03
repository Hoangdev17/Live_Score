// utils.dart
import 'package:intl/intl.dart';

String? formatUtcDate(String? utcDate) {
  if (utcDate == null) return null;

  try {
    DateTime dateTime = DateTime.parse(utcDate).toLocal();
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  } catch (e) {
    return 'Invalid Date';
  }
}
