import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/themes/themes.dart';

getApplicationTheme(bool isTv) {
  return isTv ? getTVApplicationTheme() : getMobileApplicationTheme();
}
