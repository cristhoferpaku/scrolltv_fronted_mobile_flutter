import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/font_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/style_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

ThemeData getTVApplicationTheme() {
  return ThemeData(
    // Colors of the app
    primaryColor: ColorManager.primary,
    primaryColorLight: ColorManager.primaryColorLightShadeLight,
    primaryColorDark: ColorManager.primaryColorDarkShadeLight,
    //ripple Color
    splashColor: ColorManager.primary,
    disabledColor: ColorManager.grey1, //Color used in case of disable buttons
    colorScheme: const ColorScheme(
        primary: ColorManager.primary,
        secondary: ColorManager.accent,
        //Card
        surface: ColorManager.background,
        //Scrollable Content
        error: ColorManager.error,
        onPrimary: ColorManager.white,
        onSecondary: ColorManager.black,
        onSurface: ColorManager.black,
        onError: ColorManager.white,
        brightness: Brightness.light),
    // CardView Theme
    cardTheme: const CardTheme(
        color: ColorManager.white,
        shadowColor: ColorManager.grey1,
        elevation: AppSize.s4),
    // AppBar Theme
    appBarTheme: AppBarTheme(
        centerTitle: true,
        color: ColorManager.primary,
        elevation: AppSize.s4,
        shadowColor: ColorManager.primaryLight,
        titleTextStyle:
            getRegularStyle(color: ColorManager.white, fontsize: FontSize.s24),
        systemOverlayStyle: const SystemUiOverlayStyle(
            //Color status bar notification
            statusBarColor: ColorManager.background,
            statusBarBrightness: Brightness.dark)),
    // BUtton Theme
    buttonTheme: const ButtonThemeData(
        shape: StadiumBorder(),
        disabledColor: ColorManager.grey1,
        buttonColor: ColorManager.primary,
        splashColor: ColorManager.primaryLight),
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      textStyle: getRegularStyle(color: ColorManager.white),
      backgroundColor: ColorManager.primary,
      foregroundColor: ColorManager.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s12)),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      minimumSize: const Size(double.infinity, 48.0),
    )),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: getRegularStyle(color: ColorManager.white),
        side: const BorderSide(color: ColorManager.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s12),
        ),
        foregroundColor: ColorManager.white,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        minimumSize: const Size(double.infinity, 48.0),
      ),
    ),
    // Text Theme
    textTheme: TextTheme(
      displayLarge: getBoldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyMontserrat,
          fontsize: FontSize.s64,
          fontWeight: FontWeight.w700),
      displayMedium: getBoldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyMontserrat,
          fontsize: FontSize.s52,
          fontWeight: FontWeight.w700),
      displaySmall: getBoldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyMontserrat,
          fontsize: FontSize.s44,
          fontWeight: FontWeight.w700),
      headlineLarge: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyMontserrat,
          fontsize: FontSize.s40,
          fontWeight: FontWeight.w600),
      headlineMedium: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyMontserrat,
          fontsize: FontSize.s36,
          fontWeight: FontWeight.w600),
      headlineSmall: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyMontserrat,
          fontsize: FontSize.s32,
          fontWeight: FontWeight.w600),
      titleLarge: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s36,
          fontWeight: FontWeight.w600),
      titleMedium: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s32,
          fontWeight: FontWeight.w700),
      titleSmall: getBoldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s28,
          fontWeight: FontWeight.w700),
      bodyLarge: getRegularStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s32,
          fontWeight: FontWeight.w400),
      bodyMedium: getRegularStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s24,
          fontWeight: FontWeight.w400),
      bodySmall: getRegularStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s20,
          fontWeight: FontWeight.w400),
      labelLarge: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s24,
          fontWeight: FontWeight.w600),
      labelMedium: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s20,
          fontWeight: FontWeight.w600),
      labelSmall: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyMontserrat,
          fontsize: FontSize.s18,
          fontWeight: FontWeight.w600),
    ),
    // InputDecorationTheme (text form field)
    inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.all(AppPadding.p8),
        hintStyle: getRegularStyle(color: ColorManager.grayDisabled),
        labelStyle: getMediumStyle(color: ColorManager.grayDisabled),
        errorStyle: getRegularStyle(color: ColorManager.error),
        disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
                color: ColorManager.grayDisabled, width: AppSize.s1_5),
            borderRadius: BorderRadius.all(Radius.circular(AppSize.s8))),
        enabledBorder: const OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.grey1, width: AppSize.s1_5),
            borderRadius: BorderRadius.all(Radius.circular(AppSize.s8))),
        focusedBorder: const OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.primary, width: AppSize.s1_5),
            borderRadius: BorderRadius.all(Radius.circular(AppSize.s8))),
        errorBorder: const OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.error, width: AppSize.s1_5),
            borderRadius: BorderRadius.all(Radius.circular(AppSize.s8))),
        focusedErrorBorder: const OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.primary, width: AppSize.s1_5),
            borderRadius: BorderRadius.all(Radius.circular(AppSize.s8)))),
    unselectedWidgetColor: ColorManager.darkGray,
  );
}

ThemeData getTVApplicationDarkTheme() {
  return ThemeData(
    // Colors of the app
    primaryColor: ColorManager.primary,
    primaryColorLight: ColorManager.primaryDarkColorLightShadeDark,
    primaryColorDark: ColorManager.primaryDarkColorDarkShadeDark,
    //ripple Color
    splashColor: ColorManager.accent,
    disabledColor: ColorManager.grey1, //Color used in case of disable buttons
    colorScheme: const ColorScheme(
        primary: ColorManager.primary,
        secondary: ColorManager.accent,
        //Card
        surface: ColorManager.background,
        //Scrollable Content
        error: ColorManager.error,
        onPrimary: ColorManager.white,
        onSecondary: ColorManager.black,
        onSurface: ColorManager.black,
        onError: ColorManager.white,
        brightness: Brightness.light),
    // CardView Theme
    cardTheme: const CardTheme(
        color: ColorManager.darkGray,
        shadowColor: ColorManager.grey1,
        elevation: AppSize.s4),
    // AppBar Theme
    appBarTheme: AppBarTheme(
        centerTitle: true,
        color: ColorManager.primary,
        elevation: AppSize.s4,
        shadowColor: ColorManager.primaryLight,
        titleTextStyle:
            getRegularStyle(color: ColorManager.white, fontsize: FontSize.s24),
        systemOverlayStyle: const SystemUiOverlayStyle(
            //Color status bar notification
            statusBarColor: ColorManager.background,
            statusBarBrightness: Brightness.dark)),
    // BUtton Theme
    buttonTheme: const ButtonThemeData(
        shape: StadiumBorder(),
        disabledColor: ColorManager.grey1,
        buttonColor: ColorManager.primary,
        splashColor: ColorManager.primaryLight),
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      textStyle: getRegularStyle(color: ColorManager.white),
      backgroundColor: ColorManager.primary,
      foregroundColor: ColorManager.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s12)),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      minimumSize: const Size(double.infinity, 48.0),
    )),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: getRegularStyle(color: ColorManager.white),
        side: const BorderSide(color: ColorManager.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s12),
        ),
        foregroundColor: ColorManager.white,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        minimumSize: const Size(double.infinity, 48.0),
      ),
    ),
    // Text Theme
    textTheme: TextTheme(
      displayLarge: getBoldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyMontserrat,
          fontsize: FontSize.s64,
          fontWeight: FontWeight.w700),
      displayMedium: getBoldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyMontserrat,
          fontsize: FontSize.s52,
          fontWeight: FontWeight.w700),
      displaySmall: getBoldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyMontserrat,
          fontsize: FontSize.s44,
          fontWeight: FontWeight.w700),
      headlineLarge: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyMontserrat,
          fontsize: FontSize.s40,
          fontWeight: FontWeight.w600),
      headlineMedium: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyMontserrat,
          fontsize: FontSize.s36,
          fontWeight: FontWeight.w600),
      headlineSmall: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyMontserrat,
          fontsize: FontSize.s32,
          fontWeight: FontWeight.w600),
      titleLarge: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s36,
          fontWeight: FontWeight.w600),
      titleMedium: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s32,
          fontWeight: FontWeight.w700),
      titleSmall: getBoldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s28,
          fontWeight: FontWeight.w700),
      bodyLarge: getRegularStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s32,
          fontWeight: FontWeight.w400),
      bodyMedium: getRegularStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s24,
          fontWeight: FontWeight.w400),
      bodySmall: getRegularStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s20,
          fontWeight: FontWeight.w400),
      labelLarge: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s24,
          fontWeight: FontWeight.w600),
      labelMedium: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyInter,
          fontsize: FontSize.s20,
          fontWeight: FontWeight.w600),
      labelSmall: getSemiboldStyle(
          color: ColorManager.onSurface,
          fontFamily: FontManager.fontFamilyMontserrat,
          fontsize: FontSize.s18,
          fontWeight: FontWeight.w600),
    ),
    // InputDecorationTheme (text form field)
    inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.all(AppPadding.p8),
        hintStyle: getRegularStyle(color: ColorManager.grayDisabled),
        labelStyle: getMediumStyle(color: ColorManager.grayDisabled),
        errorStyle: getRegularStyle(color: ColorManager.error),
        enabledBorder: const OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.white, width: AppSize.s1_5),
            borderRadius: BorderRadius.all(Radius.circular(AppSize.s8))),
        focusedBorder: const OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.primary, width: AppSize.s1_5),
            borderRadius: BorderRadius.all(Radius.circular(AppSize.s8))),
        errorBorder: const OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.error, width: AppSize.s1_5),
            borderRadius: BorderRadius.all(Radius.circular(AppSize.s8))),
        focusedErrorBorder: const OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.primary, width: AppSize.s1_5),
            borderRadius: BorderRadius.all(Radius.circular(AppSize.s8)))),
    unselectedWidgetColor: ColorManager.darkGray,
  );
}
