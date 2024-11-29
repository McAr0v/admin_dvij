import 'dart:io';
import 'package:flutter/material.dart';

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

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<dynamic> pushToPageWithResult({required BuildContext context, dynamic page}) async{
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  void popBackToPreviousPageWithResult({required BuildContext context, dynamic result}){
    Navigator.of(context).pop(result);
  }

  Future<void> pushAndDeletePreviousPages({required BuildContext context, dynamic page}) async {
    await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => page,
        ),
            (_) => false
    );
  }



}