import 'dart:convert';
import 'package:flutter/material.dart';

class RegularDate {
  TimeOfDay? mondayStart;
  TimeOfDay? mondayEnd;
  TimeOfDay? tuesdayStart;
  TimeOfDay? tuesdayEnd;
  TimeOfDay? wednesdayStart;
  TimeOfDay? wednesdayEnd;
  TimeOfDay? thursdayStart;
  TimeOfDay? thursdayEnd;
  TimeOfDay? fridayStart;
  TimeOfDay? fridayEnd;
  TimeOfDay? saturdayStart;
  TimeOfDay? saturdayEnd;
  TimeOfDay? sundayStart;
  TimeOfDay? sundayEnd;

  RegularDate({
    this.mondayStart,
    this.mondayEnd,
    this.tuesdayStart,
    this.tuesdayEnd,
    this.wednesdayStart,
    this.wednesdayEnd,
    this.thursdayStart,
    this.thursdayEnd,
    this.fridayStart,
    this.fridayEnd,
    this.saturdayStart,
    this.saturdayEnd,
    this.sundayStart,
    this.sundayEnd,
  });

  /// Метод для создания RegularDate из JSON
  factory RegularDate.fromJson(String jsonString) {

    final Map<String, dynamic> jsonData = json.decode(jsonString);

    TimeOfDay? parseTime(String? timeString) {
      if (timeString == null || timeString.isEmpty) return null;
      final parts = timeString.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      return null; // Возвращаем null, если формат времени неверный
    }

    return RegularDate(
      mondayStart: parseTime(jsonData['startTime1']),
      mondayEnd: parseTime(jsonData['endTime1']),
      tuesdayStart: parseTime(jsonData['startTime2']),
      tuesdayEnd: parseTime(jsonData['endTime2']),
      wednesdayStart: parseTime(jsonData['startTime3']),
      wednesdayEnd: parseTime(jsonData['endTime3']),
      thursdayStart: parseTime(jsonData['startTime4']),
      thursdayEnd: parseTime(jsonData['endTime4']),
      fridayStart: parseTime(jsonData['startTime5']),
      fridayEnd: parseTime(jsonData['endTime5']),
      saturdayStart: parseTime(jsonData['startTime6']),
      saturdayEnd: parseTime(jsonData['endTime6']),
      sundayStart: parseTime(jsonData['startTime7']),
      sundayEnd: parseTime(jsonData['endTime7']),
    );
  }

  /// Метод для преобразования в строку JSON
  String toJsonString() {
    final Map<String, String> scheduleMap = {
      "startTime1": _formatTime(mondayStart),
      "endTime1": _formatTime(mondayEnd),
      "startTime2": _formatTime(tuesdayStart),
      "endTime2": _formatTime(tuesdayEnd),
      "startTime3": _formatTime(wednesdayStart),
      "endTime3": _formatTime(wednesdayEnd),
      "startTime4": _formatTime(thursdayStart),
      "endTime4": _formatTime(thursdayEnd),
      "startTime5": _formatTime(fridayStart),
      "endTime5": _formatTime(fridayEnd),
      "startTime6": _formatTime(saturdayStart),
      "endTime6": _formatTime(saturdayEnd),
      "startTime7": _formatTime(sundayStart),
      "endTime7": _formatTime(sundayEnd),
    };

    return scheduleMap.toString().replaceAll("'", '"');
  }

  /// Вспомогательный метод для форматирования времени
  String _formatTime(TimeOfDay? time) {
    if (time == null) return ''; // Возвращаем пустую строку, если времени нет
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

}