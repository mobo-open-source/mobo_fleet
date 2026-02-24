import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_data.dart';

class AllDesigns {
  /// All design colors for this app
  static const Color appColor = AppTheme.primaryColor;
  static const Color whiteColor = AppTheme.secondaryColor;
  static const Color blackColor = Colors.black;

  static Color white = Colors.white;

  static Color grey = Colors.grey;
  static Color grey50 = Colors.grey.shade50;
  static Color greyShade100Color = Colors.grey.shade100;
  static Color greyShade300Color = Colors.grey.shade300;
  static Color greyShade400Color = Colors.grey.shade400;
  static Color greyShade500Color = Colors.grey.shade500;
  static Color greyShade600Color = Colors.grey.shade600;
  static Color greyShade700Color = Colors.grey.shade700;
  static Color greyShade800Color = Colors.grey.shade800;
  static Color greyShade900Color = Colors.grey.shade900;

  static Color yellow500 = Colors.yellow.shade500;

  static Color red = Colors.red;
  static Color red50 = Colors.red.shade50;
  static Color red500 = Colors.red.shade500;

  static Color black12 = Colors.black12;
  static Color black26 = Colors.black26;
  static Color black54 = Colors.black54;

  static Color green = Colors.green;
  static Color green50 = Colors.green.shade50;
  static Color green600 = Colors.green.shade600;

  static Color blue = Colors.blue;
  static Color blue50 = Colors.blue.shade50;
}

/// Image converter
class AssetImageConvert {
  static const AssetImage loginBgImage = AssetImage("assets/bgImage.png");
  static const AssetImage carImage = AssetImage("assets/fleet_car.png");
  static const AssetImage bikeImage = AssetImage("assets/fleet_bike.png");
  static const AssetImage emptyImage = AssetImage("assets/empty.jpg");
}

/// Font style - Monserrat
TextStyle monserratGoogleStyle({
  required double? fontSize,
  required FontWeight fontWeight,
  required Color color,
  required double? letterSpacing,
}) {
  return GoogleFonts.montserrat(
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
  );
}

/// Font style - Custom font
TextStyle myCustomStyle({
  required double? fontSize,
  required FontWeight fontWeight,
  required Color color,
  required double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: 'MyCustomFont',
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
  );
}

/// Activity tabs index
class ActivityTabs {
  static const int fuel = 0;
  static const int odometer = 1;
  static const int service = 2;
  static const int contract = 3;
}
