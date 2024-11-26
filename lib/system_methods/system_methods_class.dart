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

  Future<dynamic> showPopUpDialog({
    required BuildContext context,
    required dynamic page
  }) async {

    final selectedItem = await Navigator.of(context).push(_createRouteToPopUp(page));

    if (selectedItem != null) {
      return selectedItem;
    }
  }

  Route _createRouteToPopUp(dynamic page) {

    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        return page;
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 100),

    );
  }

}