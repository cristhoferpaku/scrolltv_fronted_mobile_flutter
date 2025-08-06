import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/font_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/style_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

ThemeData getApplicationTheme() {
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
        brightness: Brightness.light
    ),
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
            titleTextStyle: getRegularStyle(color: ColorManager.white, fontsize: FontSize.s24),
            systemOverlayStyle: const SystemUiOverlayStyle(
            //Color status bar notification
                statusBarColor: ColorManager.background,
                statusBarBrightness: Brightness.dark
        )),
    // BUtton Theme
        buttonTheme: const ButtonThemeData(
            shape: StadiumBorder(),
            disabledColor: ColorManager.grey1,
            buttonColor: ColorManager.primary,
            splashColor: ColorManager.primaryLight
        ),
    // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: getRegularStyle(color: ColorManager.white),
              backgroundColor: ColorManager.primary,
              foregroundColor: ColorManager.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.s12)
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0), 
              minimumSize: const Size(double.infinity, 48.0),
            )
        ),
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
      displayLarge: getMediumStyle(color: ColorManager.primary,  fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s60, fontWeight: FontWeight.w900),
      displayMedium: getMediumStyle(color: ColorManager.primary, fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s48, fontWeight: FontWeight.w900),
      displaySmall: getMediumStyle(color: ColorManager.primary,  fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s24, fontWeight: FontWeight.w900),
      headlineLarge: getMediumStyle(color: ColorManager.black, fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s24, fontWeight: FontWeight.w800),
      headlineMedium: getMediumStyle(color: ColorManager.black, fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s20, fontWeight: FontWeight.w800),
      headlineSmall: getMediumStyle(color: ColorManager.black, fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s16, fontWeight: FontWeight.w800),
      titleLarge: getBoldStyle(color: ColorManager.primary, fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s24),
      titleMedium: getBoldStyle(color: ColorManager.primary, fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s18),
      titleSmall: getBoldStyle(color: ColorManager.primary, fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s14),
      bodyLarge: getRegularStyle(color: ColorManager.black, fontFamily: FontManager.fontFamilySatoshi, fontsize: FontSize.s20),
      bodyMedium: getRegularStyle(color: ColorManager.black, fontFamily: FontManager.fontFamilySatoshi, fontsize: FontSize.s16),
      bodySmall: getRegularStyle(color: ColorManager.black, fontFamily: FontManager.fontFamilySatoshi, fontsize: FontSize.s12),
      labelLarge: getRegularStyle(color: ColorManager.primary, fontFamily: FontManager.fontFamilySatoshi, fontsize: FontSize.s18),
      labelMedium: getRegularStyle(color: ColorManager.primary, fontFamily: FontManager.fontFamilySatoshi, fontsize: FontSize.s16),
      labelSmall: getRegularStyle(color: ColorManager.primary, fontFamily: FontManager.fontFamilySatoshi, fontsize: FontSize.s14),
    ),
    // InputDecorationTheme (text form field)
    inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.all(AppPadding.p8),
        hintStyle: getRegularStyle(color: ColorManager.grayDisabled),
        labelStyle: getMediumStyle(color: ColorManager.grayDisabled),
        errorStyle: getRegularStyle(color: ColorManager.error),
        disabledBorder: const OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.grayDisabled, width: AppSize.s1_5),
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


ThemeData getApplicationDarkTheme() {
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
        elevation: AppSize.s4
    ),
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
            splashColor: ColorManager.primaryLight
        ),
    // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: getRegularStyle(color: ColorManager.white),
              backgroundColor: ColorManager.primary,
              foregroundColor: ColorManager.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.s12)
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0), 
              minimumSize: const Size(double.infinity, 48.0),
            )
        ),
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
      displayLarge: getMediumStyle(color: ColorManager.primary,  fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s60, fontWeight: FontWeight.w900),
      displayMedium: getMediumStyle(color: ColorManager.primary, fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s48, fontWeight: FontWeight.w900),
      displaySmall: getMediumStyle(color: ColorManager.primary,  fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s24, fontWeight: FontWeight.w900),
      headlineLarge: getMediumStyle(color: ColorManager.black,  fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s24, fontWeight: FontWeight.w600),
      headlineMedium: getMediumStyle(color: ColorManager.black, fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s20, fontWeight: FontWeight.w600),
      headlineSmall: getMediumStyle(color: ColorManager.black, fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s16, fontWeight: FontWeight.w600),
      titleLarge: getBoldStyle(color: ColorManager.primary, fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s24),
      titleMedium: getBoldStyle(color: ColorManager.primary, fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s18),
      titleSmall: getBoldStyle(color: ColorManager.primary, fontFamily: FontManager.fontFamilySpaceGrotesk, fontsize: FontSize.s14),
      bodyLarge: getRegularStyle(color: ColorManager.black, fontFamily: FontManager.fontFamilySatoshi, fontsize: FontSize.s20),
      bodyMedium: getRegularStyle(color: ColorManager.black, fontFamily: FontManager.fontFamilySatoshi, fontsize: FontSize.s16),
      bodySmall: getRegularStyle(color: ColorManager.black, fontFamily: FontManager.fontFamilySatoshi, fontsize: FontSize.s12),
      labelLarge: getRegularStyle(color: ColorManager.primary, fontFamily: FontManager.fontFamilySatoshi, fontsize: FontSize.s18),
      labelMedium: getRegularStyle(color: ColorManager.primary, fontFamily: FontManager.fontFamilySatoshi, fontsize: FontSize.s16),
      labelSmall: getRegularStyle(color: ColorManager.primary, fontFamily: FontManager.fontFamilySatoshi, fontsize: FontSize.s14),
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
