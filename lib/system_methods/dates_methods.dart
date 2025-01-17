import 'package:admin_dvij/constants/errors_constants.dart';
import 'package:flutter/material.dart';

class DateMethods{

  /// Возвращает время в формате: 16:00 - 23:00
  String getTimePeriod({required TimeOfDay? startTime, required TimeOfDay? endTime}) {
    if (startTime != null && endTime != null){
      // Форматируем время начала и завершения
      final start = _formatTimeOfDay(startTime);
      final end = _formatTimeOfDay(endTime);
      return "$start - $end";
    } else {
      return ErrorConstants.noChosenTime;
    }

  }

  /// Утилита для форматирования TimeOfDay в строку вида "HH:mm"
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String formatTimeOrDateWithZero(int dayOrMonth){
    if (dayOrMonth < 10) {
      return '0$dayOrMonth';
    } else {
      return '$dayOrMonth';
    }
  }

  String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (date.year == 2100){
      return 'Еще не выполнил вход';
    } else {
      if (difference.inSeconds < 60) {
        return 'только что';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} минуту назад';
      } else if (difference.inHours < 24) {
        final hours = difference.inHours;
        return '$hours час${hours == 1 ? '' : 'а'} назад';
      } else if (difference.inDays < 7) {
        final days = difference.inDays;
        return '$days день${days == 1 ? '' : 'я'} назад';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks недел${weeks == 1 ? 'ю' : 'и'} назад';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months месяц${months == 1 ? '' : 'а'} назад';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years год${years == 1 ? '' : 'а'} назад';
      }
    }
  }

}