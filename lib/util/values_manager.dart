import 'package:flutter/material.dart';

class AppEdgeInsets {
  //Horizontal Margin
  static const EdgeInsets horizontalMargin48 =
      EdgeInsets.symmetric(horizontal: AppMargin.m48);
  static const EdgeInsets horizontalMargin40 =
      EdgeInsets.symmetric(horizontal: AppMargin.m40);
  static const EdgeInsets horizontalMargin32 =
      EdgeInsets.symmetric(horizontal: AppMargin.m32);
  static const EdgeInsets horizontalMargin24 =
      EdgeInsets.symmetric(horizontal: AppMargin.m24);
  static const EdgeInsets horizontalMargin16 =
      EdgeInsets.symmetric(horizontal: AppMargin.m16);

  static const EdgeInsets symetricMarginv8h16 =
      EdgeInsets.symmetric(horizontal: AppMargin.m16, vertical: AppMargin.m8);

  // All
  static EdgeInsets all(double sized) {
    return EdgeInsets.all(sized);
  }

  //Custom Padding
  static EdgeInsets bottom(double sized) {
    return EdgeInsets.only(bottom: sized);
  }
}

class AppMargin {
  static const double m2 = 2.0;
  static const double m4 = 4.0;
  static const double m8 = 8.0;
  static const double m10 = 10.0;
  static const double m12 = 12.0;
  static const double m16 = 16.0;
  static const double m20 = 20.0;
  static const double m24 = 24.0;
  static const double m32 = 32.0;
  static const double m36 = 36.0;
  static const double m40 = 36.0;
  static const double m48 = 48.0;
  static const double m56 = 56.0;
  static const double m64 = 64.0;
  static const double m72 = 72.0;
  static const double m80 = 80.0;
  static const double m88 = 88.0;
  static const double m96 = 96.0;
}

class AppPadding {
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p10 = 10.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p18 = 18.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
  static const double p48 = 48.0;
  static const double p56 = 56.0;
  static const double p64 = 64.0;
}

class AppSize {
  static const double s1_5 = 1.5;
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s10 = 10.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s18 = 18.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s36 = 36.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s56 = 56.0;
  static const double s60 = 60.0;
  static const double s80 = 80.0;
  static const double s90 = 90.0;
  static const double s100 = 100.0;
  static const double s120 = 120.0;
  static const double s140 = 140.0;
  static const double s145 = 145.0;
  static const double s150 = 150.0;
  static const double s160 = 160.0;
  static const double s180 = 180.0;
  static const double s200 = 200.0;
  static const double s220 = 220.0;
  static const double s250 = 250.0;
  static const double s280 = 280.0;
  static const double s300 = 300.0;
  static const double s350 = 350.0;
  static const double s400 = 400.0;
}

class DimenReponsive {
  static const int mobileDimen = 600;
  static const int tabletDimen = 900;
  static const int desktopDimen = 1024;
}

class AppDuration {
  static const Duration d300 = Duration(microseconds: 300);
}

class AppElevation {
  static const double lowElevation = 8;
}
