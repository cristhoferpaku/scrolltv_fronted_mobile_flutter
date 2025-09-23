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
  return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
}

// String formatDuration(Duration duration) {
//   String twoDigits(int n) => n.toString().padLeft(2, '0');
//   final hours = duration.inHours;
//   final minutes = duration.inMinutes.remainder(60);
//   final seconds = duration.inSeconds.remainder(60);

//   if (hours > 0) {
//     return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
//   } else {
//     return '${twoDigits(minutes)}:${twoDigits(seconds)}';
//   }
// }

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

  if (duration.inHours > 0) {
    return '${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds';
  } else {
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}
