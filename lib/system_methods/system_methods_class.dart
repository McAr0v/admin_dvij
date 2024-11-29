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

  String _pluralize(int number, String singular, String pluralFew, String pluralMany) {
    if (number % 10 == 1 && number % 100 != 11) return singular;
    if (number % 10 >= 2 && number % 10 <= 4 && (number % 100 < 10 || number % 100 >= 20)) return pluralFew;
    return pluralMany;
  }

  String calculateYears(DateTime date) {
    final now = DateTime.now();
    int years = now.year - date.year;

    if (years <= 0){
      return 'Дата рождения не выбрана';
    } else {
      // Проверяем, прошел ли полный год
      if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
        years--;
      }
      // Определяем правильное склонение слова "год"
      return '$years ${_pluralize(years, "год", "года", "лет")}';
    }
  }

  String calculateExperienceTime(DateTime date) {
    final now = DateTime.now();

    if (isSameDay(date, now)){
      return '0 дней';
    } else {
      // Разбиваем Duration на годы, месяцы и дни
      int years = now.year - date.year;
      int months = now.month - date.month;
      int days = now.day - date.day;

      // Корректируем отрицательные значения для месяцев и дней
      if (days < 0) {
        final previousMonth = DateTime(now.year, now.month - 1, date.day);
        days = now.difference(previousMonth).inDays;
        months -= 1;
      }

      if (months < 0) {
        years -= 1;
        months += 12;
      }

      // Формируем строку
      final yearsText = years > 0 ? '$years ${_pluralize(years, "год", "года", "лет")}' : '';
      final monthsText = months > 0 ? '$months ${_pluralize(months, "месяц", "месяца", "месяцев")}' : '';
      final daysText = days > 0 ? '$days ${_pluralize(days, "день", "дня", "дней")}' : '';

      // Собираем строку с правильными пробелами
      return [yearsText, monthsText, daysText].where((text) => text.isNotEmpty).join(', ');
    }


  }

}