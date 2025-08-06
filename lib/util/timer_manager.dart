
import 'package:timezone/timezone.dart';

TZDateTime convertToTZDateTime(
  DateTime dateTime, {
  int hour = 0,
  int minute = 0,
  int second = 0,
  String timezone = 'America/Lima',
}) {
  assert(hour >= 0 && hour < 24, 'Hour must be between 0 and 23');
  assert(minute >= 0 && minute < 60, 'Minute must be between 0 and 59');
  assert(second >= 0 && second < 60, 'Second must be between 0 and 59');

  final Location location = getLocation(timezone);

  return TZDateTime(
    location,
    dateTime.year,
    dateTime.month,
    dateTime.day,
    hour,
    minute,
    second,
  );
}

TZDateTime convertStringToTZDateTime(
  String dateTimeString, {
  String timezone = 'America/Lima',
}) {
  try {
    // Parsea el String a DateTime (interpreta UTC si el String incluye 'Z')
    final DateTime dateTime = DateTime.parse(dateTimeString).toUtc();

    // Obtiene la ubicación (zona horaria) deseada
    final Location location = getLocation(timezone);

    // Convierte el DateTime a TZDateTime en la zona horaria especificada
    return TZDateTime.from(dateTime, location);
  } catch (e) {
    throw FormatException('Invalid date format: $dateTimeString');
  }
}