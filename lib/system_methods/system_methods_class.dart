import 'dart:io';
import 'package:admin_dvij/constants/date_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/system_methods/dates_methods.dart';
import 'package:flutter/material.dart';

import '../constants/buttons_constants.dart';

class SystemMethodsClass {
  SystemMethodsClass();

  double getScreenWidth({double neededWidth = 600}){

    bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    return isDesktop ? neededWidth : double.infinity;

  }

  Future<dynamic> getPopup({ required BuildContext context, required dynamic page}) async{
    return await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return page;
      },
    );
  }

  String formatDateTimeToHumanView(DateTime date) {
    const List<String> months = [
      "января", "февраля", "марта", "апреля", "мая", "июня",
      "июля", "августа", "сентября", "октября", "ноября", "декабря"
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String formatMonthToEnglish(DateTime date) {
    const List<String> months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];

    return months[date.month - 1];
  }

  String formatDayWithDashes(DateTime date) {
    return '-${date.day}-';
  }

  String formatDateTimeToHumanViewWithClock(DateTime date) {
    const List<String> months = [
      "января", "февраля", "марта", "апреля", "мая", "июня",
      "июля", "августа", "сентября", "октября", "ноября", "декабря"
    ];

    DateMethods dm = DateMethods();

    return '${date.day} ${months[date.month - 1]} ${date.year}, ${dm.formatTimeOrDateWithZero(date.hour)}:${dm.formatTimeOrDateWithZero(date.minute)}';
  }

  String formatTimeAgo(DateTime date) {
    final now = DateTime.now().toUtc().copyWith(microsecond: 0, millisecond: 0);
    final correctedDate = date.toUtc().copyWith(microsecond: 0, millisecond: 0);
    final difference = now.difference(correctedDate);

    if (date.year == 2100) {
      return SystemConstants.awaitingConfirmEmail;
    } else if (difference.inSeconds < 60) {
      return 'только что';
    } else if (difference.inMinutes < 60) {
      final min = difference.inMinutes;
      return '$min ${_pluralize(min, 'минуту', 'минуты', 'минут')} назад';
    } else if (difference.inHours < 24) {
      final hrs = difference.inHours;
      return '$hrs ${_pluralize(hrs, 'час', 'часа', 'часов')} назад';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${_pluralize(days, 'день', 'дня', 'дней')} назад';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${_pluralize(weeks, 'неделю', 'недели', 'недель')} назад';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${_pluralize(months, 'месяц', 'месяца', 'месяцев')} назад';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${_pluralize(years, 'год', 'года', 'лет')} назад';
    }
  }


  String formatTimeToHumanView(TimeOfDay time){
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  int applyDiscountAndRoundUp(int value, double percent) {
    double discountedValue = value * (1 - percent / 100);
    return (discountedValue / 5).ceil() * 5;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<DateTime?> dataPicker({
    required BuildContext context,
    DateTime? currentDate,
    required String label,
    required DateTime firstDate,
    required DateTime lastDate,
    bool needCalendar = false
  }) async{
    DateTime initial = DateTime.now();

    if (currentDate != null) {
      initial = currentDate;
    }

    return await showDatePicker(

      locale: const Locale('ru'), // Локализация (например, русский)
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: DateConstants.chosenDate,
      cancelText: ButtonsConstants.cancel,
      confirmText: ButtonsConstants.ok,
      keyboardType: TextInputType.datetime,
      initialEntryMode: !needCalendar ? DatePickerEntryMode.inputOnly : DatePickerEntryMode.calendar,
      fieldLabelText: label
    );
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
      return DateConstants.noBirthDate;
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

  /// Проверяет, пересекаются ли 2 диапазона дат
  bool dateCrash(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    // Проверяем, чтобы один диапазон заканчивался раньше, чем начался другой
    return end1.isBefore(start2) || end2.isBefore(start1);
  }

}