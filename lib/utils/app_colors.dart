import 'dart:ui';

import 'package:flutter/material.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class AppColors {
  static Color primary = HexColor.fromHex("#573174");
  static Color primaryTranseparent = Color.fromARGB(47, 87, 49, 116);
  static Color secondary = HexColor.fromHex("#35c3ae");
  static Color primaryLight = HexColor.fromHex("#9779ad");
  static Color danger = HexColor.fromHex('#f0382b');
  static Color success = HexColor.fromHex('#5d9126');
  static Color checkinGreen = HexColor.fromHex('#2f9d58');
  static Color checkoutRed = HexColor.fromHex('#e24c4c');
  static Color checkinGreenBg = HexColor.fromHex('#eaf5ee');
  static Color checkoutRedBg = HexColor.fromHex('#fff5f5');
  static Color checkoutHome = HexColor.fromHex('#809d58');
  static Color checkoutHomeBg = HexColor.fromHex('#EAF5EE');
  static Color checkouthalf = HexColor.fromHex('#F88B7C');
  static Color checkouthalfBg = HexColor.fromHex('#FFF5F0');
  static Color orange = HexColor.fromHex('#f8814f');
  static Color orangeBg = HexColor.fromHex('#fff5f0');
  static Color black = HexColor.fromHex('#000000');
  static Color white = HexColor.fromHex('#FFFFFF');
  static Color textWhiteGrey = const Color(0xfff1f1f5);
  static Color textGrey = const Color(0xff909292);
  static Color bgGreyLight = HexColor.fromHex('#f4f5f6');
  static Color light_grey = HexColor.fromHex('#999999');
  static Color lightGreyColor = Color.fromRGBO(216, 216, 216, 0.4);
  static Color darkGreyColor = HexColor.fromHex("#454545");
  static Color hint_color = AppColors.white.withOpacity(0.6);
  static Color field_color = AppColors.grey.withOpacity(0.3);
  static Color colorScreenBackground = HexColor.fromHex('#1C1D21');
  static Color colorGrey = HexColor.fromHex('#8D8989');
  static Color other_color = HexColor.fromHex('#19191a');
  static Color grey = HexColor.fromHex('#707070');
  static Color my_peach_color = HexColor.fromHex('#FFDAB9');
  static Color btn_color = HexColor.fromHex('#E02529');
  static Color app_color = HexColor.fromHex('#262627');
  static Color light_app_color = HexColor.fromHex('#363637');
  static Color dark_text_color = HexColor.fromHex('#828282');
  static Color light_btn_color = HexColor.fromHex('#707070');
  // static Color colorBtnEnd = HexColor.fromHex('#13CCBD');
  static Color colorBtnEnd = HexColor.fromHex('#14CDBB');
  // static Color colorBtnStart = HexColor.fromHex('#29E68F');
  static Color colorBtnStart = HexColor.fromHex('#27E492');
  static Color colorTextField = HexColor.fromHex('#FFFFFF');
  static Color colorWhite = HexColor.fromHex('#FFFFFF');
  static Color colorWhiteOff = HexColor.fromHex('#D7D7D7');
  static Color colorBlack = HexColor.fromHex('#000000');
  static Color colorBtnText1 = HexColor.fromHex('#1ED9A5');
  static Color colorTransparentNull = HexColor.fromHex('#00EAF8ED');
  static Color colorTransparent = HexColor.fromHex('#51000000');
  // static Color colorBlackLight = HexColor.fromHex('#2F3138');
  static Color colorBlackLight = HexColor.fromHex('#2F3138');
  static Color colorBgDialog = HexColor.fromHex('#343537');
  static Color colorBgDialogInsideView = HexColor.fromHex('#545454');
  // static Color colorMenuUnSelected = grey;
  // static Color colorMenuSelected = white;
  static Color colorWhiteOffSmall = HexColor.fromHex('#AEFFFFFF');
  static Color colorBgAudioGrey = HexColor.fromHex('#737373');
  // static Color colorBgAudioGrey = HexColor.fromHex('#7E7C7C');
  static Color colorAudioWaveBar = HexColor.fromHex('#1DD8A7');
  static MaterialColor appColor = MaterialColor(0xFFFFFFFF, color);
  static Color textPurpleColor = const Color(0xFF563174);
  static Color textPurpleColorWithOpacity = Color(0x25563174);
  static Color colorDialogTransparentBackground = Colors.black.withOpacity(0.8);
}

Map<int, Color> color = {
  50: Color(0xFF262627),
  100: Color(0xFF262627),
  200: Color(0xFF262627),
  300: Color(0xFF262627),
  400: Color(0xFF262627),
  500: Color(0xFF262627),
  600: Color(0xFF262627),
  700: Color(0xFF262627),
  800: Color(0xFF262627),
  900: Color(0xFF262627),
};
