import 'package:intl/intl.dart';

String getStringByLanguage(
    String? currentLanguage, String textToSpanish, String textToEnglish) {
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


        