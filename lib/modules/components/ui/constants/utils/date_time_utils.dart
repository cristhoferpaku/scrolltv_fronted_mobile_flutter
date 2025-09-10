import 'package:intl/intl.dart';

String getHourMinute({DateTime? date}) {
  final now = date ?? DateTime.now().toLocal();
  return DateFormat.Hm().format(now); // HH:mm según el locale del dispositivo
}

String getDayName({DateTime? date}) {
  final now = date ?? DateTime.now().toLocal();
  return DateFormat.E().format(now); // Lunes, Martes, etc.
}

String getDate({DateTime? date}) {
  final now = date ?? DateTime.now().toLocal();
  return DateFormat.yMd().format(now); // dd/MM/yyyy según el locale del dispositivo
}
