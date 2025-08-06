// ignore_for_file: depend_on_referenced_packages

import 'package:intl/intl.dart';

String? formatDate(String? date) {
  if (date == null || date.isEmpty) return null;

  try {
    // Asume que la fecha está en formato ISO (yyyy-MM-dd o similar)
    final DateTime parsedDate = DateTime.parse(date);

    // Formatea la fecha al formato deseado DD/MM/YYYY
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  } catch (e) {
    // En caso de error, devuelve null o un mensaje predeterminado
    return null;
  }
}
