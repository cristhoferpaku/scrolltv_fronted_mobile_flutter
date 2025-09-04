import 'package:intl/intl.dart';

String getStringByLanguage(String? currentLanguage, String textToSpanish, String textToEnglish) {
  if (currentLanguage == 'ES' || currentLanguage == null) {
    return textToSpanish;
  } else {
    return textToEnglish;
  }
}

String getFormatDateToString(DateTime dateTime, {String format = 'dd-MM-yy'}) {
  var formatter = DateFormat(format);
  return formatter.format(dateTime);
}

String convertMinsToHoursAndMinutes(int? mins) {
  if (mins == null) return "";
  int hours = mins ~/ 60;
  int minutes = mins % 60;
  return "${hours}h ${minutes.toString().padLeft(2, '0')}min";
}

String convertIsoDateToLocal(String? isoString) {
  if (isoString == null) return "";
  final date = DateTime.parse(isoString).toLocal();
  return DateFormat('dd/MM/yyyy').format(date);
}
