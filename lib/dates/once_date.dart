import 'dart:convert';
import 'package:admin_dvij/system_methods/dates_methods.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:flutter/material.dart';

class OnceDate {
  DateTime? date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  OnceDate({
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory OnceDate.empty(){
    return OnceDate(date: null, startTime: null, endTime: null);
  }

  factory OnceDate.fromJson({required String jsonString}){

    if (jsonString.isNotEmpty){
      // Декодируем JSON-строку
      final Map<String, dynamic> json = jsonDecode(jsonString);

      // Извлекаем данные и создаем экземпляр
      final date = DateTime.parse(json['date']);
      final startTimeParts = json['startTime'].split(':').map(int.parse).toList();
      final endTimeParts = json['endTime'].split(':').map(int.parse).toList();

      return OnceDate(
        date: date,
        startTime: TimeOfDay(hour: startTimeParts[0], minute: startTimeParts[1]),
        endTime: TimeOfDay(hour: endTimeParts[0], minute: endTimeParts[1]),
      );
    } else {
     return OnceDate.empty();
    }
  }

  /// Преобразует экземпляр `OnceDate` в JSON-строку
  String toJsonString() {

    if (date != null && startTime != null && endTime != null){
      // Преобразуем объект в карту
      final Map<String, String> json = {
        'date': date!.toIso8601String().split('T').first, // Только дата
        'startTime': '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
        'endTime': '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
      };

      // Возвращаем строку в формате JSON
      return jsonEncode(json);
    } else {
      return '';
    }
  }

  /// Возвращает дату в формате: 1 января 2025 года
  String getHumanViewDate() {

    SystemMethodsClass sm = SystemMethodsClass();

    if (date != null){
      return sm.formatDateTimeToHumanView(date!);
    } else {
      return 'Дата не выбрана';
    }
  }

  /// Возвращает время в формате: 16:00 - 23:00
  String getTimePeriod() {

    DateMethods dateMethods = DateMethods();

    return dateMethods.getTimePeriod(startTime: startTime, endTime: endTime);

  }

  /// Проверяет, является ли мероприятие сегодняшним.
  bool isToday() {
    if (date == null || startTime == null || endTime == null) return false;

    final now = DateTime.now();
    final eventDate = DateTime(date!.year, date!.month, date!.day);

    // Проверяем, совпадает ли дата мероприятия с текущей датой.
    return eventDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
  }

  /// Проверяет, идет ли мероприятие в текущий момент.
  bool isOngoing() {
    if (date == null || startTime == null || endTime == null) return false;

    final now = DateTime.now();

    // Начало мероприятия
    final eventStart = DateTime(
      date!.year,
      date!.month,
      date!.day,
      startTime!.hour,
      startTime!.minute,
    );

    // Если время завершения меньше времени начала — это следующий день.
    final eventEnd = endTime!.hour < startTime!.hour
        ? DateTime(
      date!.year,
      date!.month,
      date!.day + 1,
      endTime!.hour,
      endTime!.minute,
    )
        : DateTime(
      date!.year,
      date!.month,
      date!.day,
      endTime!.hour,
      endTime!.minute,
    );

    // Проверяем, находится ли текущий момент между временем начала и завершения.
    return now.isAfter(eventStart) && now.isBefore(eventEnd);
  }

  /// Проверяет, завершилось ли мероприятие.
  bool isFinished() {
    if (date == null || startTime == null || endTime == null) return true;

    final now = DateTime.now();

    // Если время завершения меньше времени начала — это следующий день.
    final eventEnd = endTime!.hour < startTime!.hour
        ? DateTime(
      date!.year,
      date!.month,
      date!.day + 1,
      endTime!.hour,
      endTime!.minute,
    )
        : DateTime(
      date!.year,
      date!.month,
      date!.day,
      endTime!.hour,
      endTime!.minute,
    );

    // Мероприятие завершилось, если текущий момент позже времени завершения.
    return now.isAfter(eventEnd);
  }

  // Преобразуем дату и время в DateTime
  DateTime get startDateTime {
    return DateTime(
      date!.year,
      date!.month,
      date!.day,
      startTime!.hour,
      startTime!.minute,
    );
  }

  DateTime get endDateTime {
    // Если время завершения меньше времени начала, это следующий день
    if (endTime!.hour < startTime!.hour ||
        (endTime!.hour == startTime!.hour && endTime!.minute < startTime!.minute)) {
      return DateTime(
        date!.year,
        date!.month,
        date!.day + 1,
        endTime!.hour,
        endTime!.minute,
      );
    }
    return DateTime(
      date!.year,
      date!.month,
      date!.day,
      endTime!.hour,
      endTime!.minute,
    );
  }

}