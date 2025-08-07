import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/font_manager.dart';

TextStyle _getTextStyle(
  double fontSize,
  String fontFamily,
  FontWeight fontWeight,
  Color color,
) {
  return TextStyle(
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      color: color);
}

// Regular Style
TextStyle getRegularStyle({
  double fontsize = FontSize.s12,
  String fontFamily = FontManager.fontFamilyInter,
  FontWeight fontWeight = FontWeightManager.regular,
  required Color color,
}) {
  return _getTextStyle(fontsize, fontFamily, fontWeight, color);
}

// Medium Style
TextStyle getMediumStyle({
  double fontsize = FontSize.s12,
  String fontFamily = FontManager.fontFamilyInter,
  FontWeight fontWeight = FontWeightManager.medium,
  required Color color,
}) {
  return _getTextStyle(fontsize, fontFamily, fontWeight, color);
}

// Light Style
TextStyle getLightStyle({
  double fontsize = FontSize.s12,
  String fontFamily = FontManager.fontFamilyInter,
  FontWeight fontWeight = FontWeightManager.light,
  required Color color,
}) {
  return _getTextStyle(fontsize, fontFamily, fontWeight, color);
}

// Semibold Style
TextStyle getSemiboldStyle({
  double fontsize = FontSize.s12,
  String fontFamily = FontManager.fontFamilyInter,
  FontWeight fontWeight = FontWeightManager.semibold,
  required Color color,
}) {
  return _getTextStyle(fontsize, fontFamily, fontWeight, color);
}

// Bold Style
TextStyle getBoldStyle(
    {double fontsize = FontSize.s12,
    String fontFamily = FontManager.fontFamilyInter,
    FontWeight fontWeight = FontWeightManager.bold,
    Color? color}) {
  if (color != null) {
    return _getTextStyle(fontsize, fontFamily, fontWeight, color);
  } else {
    return _getDefaultTextStyle(fontsize, fontFamily, fontWeight);
  }
}

TextStyle _getDefaultTextStyle(
    double fontSize, String fontFamily, FontWeight fontWeight) {
  return TextStyle(
      fontSize: fontSize, fontFamily: fontFamily, fontWeight: fontWeight);
}
