import 'dart:io';

import 'package:flutter/cupertino.dart';

class SystemMethodsClass {
  SystemMethodsClass();

  double getScreenWidth(){

    bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    return isDesktop ? 600 : double.infinity;

  }

  String formatDateTimeToHumanView(DateTime date) {
    const List<String> months = [
      "января", "февраля", "марта", "апреля", "мая", "июня",
      "июля", "августа", "сентября", "октября", "ноября", "декабря"
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }



}