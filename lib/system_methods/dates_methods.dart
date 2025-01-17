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

}