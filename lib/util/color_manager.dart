import 'package:flutter/material.dart';

class ColorManager {
  static const Color primary = Color(0xFF3B7CF6);
  static const Color principal_200 = Color(0xFFBFD9FE);

  static const Color primaryColorLightShadeLight = Color(0xFF3B7CF6);
  static const Color primaryColorDarkShadeLight = Color(0xFF3B7CF6);
  static const Color primaryLight = Color(0xFFF57F20);
  static const Color secondary = Color(0xFFF72585);
  static const Color accent = Color(0xFFDBE9FE);
  static const Color buttonColor = Color(0xFFFF6B35);
  static const Color textLinkColor = Color.fromARGB(255, 48, 39, 168);
  static const Color textDisableLinkColor = Color(0xFF636363);
  static const Color accentDark = Color(0xFFd5aa59);
  static const Color grayBackground = Color(0xFF91959F);
  static const Color lightBlueGray = Color(0xff2C3D4A);
  static const Color background = Color(0xFFFAFAFA);
  static const Color transparent = Color(0x00000000);
  static const Color white = Color(0xFFFEFEFE);
  static const Color black = Color(0xFF1A1A1A);
  static const Color lightColorText = Color(0xFFF9F9F9);
  static const Color lightHintColorText = Color(0xFFC0C0C0);
  static const Color lightPlaceholderColorText = Color(0xFFB0B0B0);
  static const Color darkColorText = Color(0xFF14212b);
  static const Color backgroundLight = Color(0xFF14212b);
  static const Color backgroundDark = Color(0xFF14212b);
  static const Color backgroundNotification = Color(0xFFFDCB8B);

  //Color for Shimmer
  static const Color shimmerStart = Color(0xFF929292);
  static const Color shimmerEffect = Color(0xFFB2B2B2);

  //Color Social Network
  static const Color facebookColor = Color(0xFF3D5A98);
  static const Color googleColor = Color(0xFFDB4437);

  //Ripple Colors
  static const Color ripplePrimary = Color(0xFF0064B0);
  static const Color rippleAccent = Color(0xFFF67C50);

  //Color Principles
  static const Color principleColab = Color(0xFF19A3B3);
  static const Color principleTrans = Color(0xFF83b659);
  static const Color principleChange = Color(0xFFf38714);
  static const Color principleOrientation = Color(0xFF58224e);
  static const Color principleClient = Color(0xFFc13553);

  // Color Background
  static const Color containerDarkBackground = Color(0xFF23323E);

  //Theme colors
  static const Color primaryDark = Color(0xFFF16422);
  static const Color primaryDarkColorLightShadeDark = Color(0xFFF99D1C);
  static const Color primaryDarkColorDarkShadeDark = Color(0xFFF57F20);
  static const Color grayDisabled = Color(0xFF565656);
  static const Color grey1 = Color(0xFFCACACA);
  static const Color grey2 = Color(0xFF797979);
  static const Color blueGrey = Color(0xFF212D36);
  static const Color darkGray = Color(0xFF1c1c1c);
  static const Color lightgray = Color(0xFF303030);
  static const Color success = Color(0xFF00C897);
  static const Color warning = Color(0xFFFFD365);
  static const Color error = Color(0xFFDE0000);

  /*
  static Color primary = HexColor.fromHex('#2c1911');
  static Color primaryLight = HexColor.fromHex('#2c1911d6');
  static Color secondary = HexColor.fromHex('#d64211');
  static Color accent = HexColor.fromHex('#d5aa59');
  static Color accentDark = HexColor.fromHex('#d5aa59');
  static Color white = HexColor.fromHex('#FEFEFE');
  static Color black = HexColor.fromHex('#0F0F0F');

  //Theme colors
  static Color primaryDark = HexColor.fromHex('#2c1911');
  static Color grey1 = HexColor.fromHex('#707070');
  static Color grey2 = HexColor.fromHex('#797979');
  static Color darkGray = HexColor.fromHex('#1c1c1c');
  static Color lightgray = HexColor.fromHex('#303030');
  static Color success = HexColor.fromHex('#00C897');
  static Color warning = HexColor.fromHex('#FFD365');
  static Color error = HexColor.fromHex('#FF6363');
  */
}

extension HexColor on Color {
  static Color fromHex(String hexColorString) {
    hexColorString = hexColorString.replaceAll('#', '');
    if (hexColorString.length == 6) {
      hexColorString = 'FF$hexColorString';
    }
    return Color(int.parse(hexColorString, radix: 16));
  }
}
