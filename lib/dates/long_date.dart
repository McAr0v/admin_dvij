import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/system_constants.dart';
import '../design_elements/elements_of_design.dart';
import '../system_methods/dates_methods.dart';
import '../system_methods/system_methods_class.dart';

class LongDate {

  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  LongDate({
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime
  });

  factory LongDate.empty(){
    return LongDate(
        startDate: null,
        endDate: null,
        startTime: null,
        endTime: null
    );
  }

  factory LongDate.setLongDate({required LongDate fromDate}){
    LongDate longDate = LongDate.empty();

    longDate.startDate = fromDate.startDate;
    longDate.endDate = fromDate.endDate;
    longDate.startTime = fromDate.startTime;
    longDate.endTime = fromDate.endTime;

    return longDate;

  }

  factory LongDate.fromJson({required String jsonString}){

    if (jsonString.isNotEmpty){
      // Декодируем JSON-строку
      final Map<String, dynamic> json = jsonDecode(jsonString);

      // Извлекаем данные и создаем экземпляр
      final startDate = DateTime.parse(json['startDate']);
      final endDate = DateTime.parse(json['endDate']);
      final startTimeParts = json['startTime'].split(':').map(int.parse).toList();
      final endTimeParts = json['endTime'].split(':').map(int.parse).toList();

      return LongDate(
        startDate: startDate,
        endDate: endDate,
        startTime: TimeOfDay(hour: startTimeParts[0], minute: startTimeParts[1]),
        endTime: TimeOfDay(hour: endTimeParts[0], minute: endTimeParts[1]),
      );
    } else {
      return LongDate.empty();
    }
  }

  String checkDate(){
    if (startDate == null){
      return 'Дата начала не выбрана';
    } else if (endDate == null){
      return 'Дата завершения не выбрана';
    } else if (startTime == null){
      return 'Не выбрано время начала';
    } else if (endTime == null){
      return 'Не выбрано время завершения';
    } else {
      return SystemConstants.successConst;
    }
  }

  String toJsonString() {

    if (startDate != null && endDate != null && startTime != null && endTime != null){
      // Преобразуем объект в карту
      final Map<String, String> json = {
        'startDate': startDate!.toIso8601String().split('T').first, // Только дата
        'endDate': endDate!.toIso8601String().split('T').first, // Только дата
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

    if (startDate != null && endDate != null){
      return '${sm.formatDateTimeToHumanView(startDate!)} - ${sm.formatDateTimeToHumanView(endDate!)}';
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
    if (startDate == null || endDate == null || startTime == null || endTime == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Проверяем, находится ли текущая дата в диапазоне от startDate до endDate включительно.
    final eventStartDate = DateTime(startDate!.year, startDate!.month, startDate!.day);
    final eventEndDate = DateTime(endDate!.year, endDate!.month, endDate!.day);

    return today.isAfter(eventStartDate.subtract(const Duration(days: 1))) &&
        today.isBefore(eventEndDate.add(const Duration(days: 1)));
  }

  /// Проверяет, идет ли мероприятие в текущий момент.
  bool isOngoing() {
    if (startDate == null || endDate == null || startTime == null || endTime == null) return false;

    final now = DateTime.now();

    if (!isToday()){
      return false;
    }


    // Время начала мероприятия для текущего дня
    final eventStart = DateTime(
      now.year,
      now.month,
      now.day,
      startTime!.hour,
      startTime!.minute,
    );

    // Время завершения мероприятия для текущего дня
    final eventEnd = endTime!.hour < startTime!.hour
        ? DateTime(
      now.year,
      now.month,
      now.day + 1,
      endTime!.hour,
      endTime!.minute,
    ) // Завершение в следующий день
        : DateTime(
      now.year,
      now.month,
      now.day,
      endTime!.hour,
      endTime!.minute,
    );

    // Проверяем, находится ли текущее время между временем начала и завершения.
    return now.isAfter(eventStart) && now.isBefore(eventEnd);
  }

  /// Проверяет, завершилось ли мероприятие.
  bool isFinished() {
    if (startDate == null || endDate == null || startTime == null || endTime == null) return true;

    final now = DateTime.now();

    // Если время завершения меньше времени начала — это следующий день.
    final eventEnd = endTime!.hour < startTime!.hour
        ? DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day + 1,
      endTime!.hour,
      endTime!.minute,
    )
        : DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      endTime!.hour,
      endTime!.minute,
    );

    // Мероприятие завершилось, если текущий момент позже времени завершения.
    return now.isAfter(eventEnd);
  }

  Widget getLongDateWidget({
    required bool isMobile,
    required bool canEdit,
    required BuildContext context,
    required VoidCallback onStartDate,
    required VoidCallback onEndDate,
    required VoidCallback onStartTime,
    required VoidCallback onEndTime,
  }){

    SystemMethodsClass sm = SystemMethodsClass();

    TextEditingController startDateController = TextEditingController();
    TextEditingController endDateController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();

    startDateController.text = startDate != null ? sm.formatDateTimeToHumanView(startDate!) : 'Выбери дату начала';
    endDateController.text = endDate != null ? sm.formatDateTimeToHumanView(endDate!) : 'Выбери дату завершения';
    startTimeController.text = startTime != null ? sm.formatTimeToHumanView(startTime!) : 'Выбери время начала';
    endTimeController.text = endTime != null ? sm.formatTimeToHumanView(endTime!) : 'Выбери время завершения';

    return ElementsOfDesign.buildAdaptiveRow(
        isMobile: isMobile,
        children: [
          ElementsOfDesign.buildTextField(
              controller: startDateController,
              labelText: 'Дата начала проведения',
              canEdit: canEdit,
              icon: FontAwesomeIcons.calendar,
              context: context,
              readOnly: true,
              onTap: onStartDate
          ),

          ElementsOfDesign.buildTextField(
              controller: endDateController,
              labelText: 'Дата завершения проведения',
              canEdit: canEdit,
              icon: FontAwesomeIcons.calendar,
              context: context,
              readOnly: true,
              onTap: onEndDate
          ),

          ElementsOfDesign.buildTextField(
              controller: startTimeController,
              labelText: 'Время начала',
              canEdit: canEdit,
              icon: FontAwesomeIcons.signature,
              context: context,
              readOnly: true,
              onTap: onStartTime
          ),
          ElementsOfDesign.buildTextField(
              controller: endTimeController,
              labelText: 'Время завершения',
              canEdit: canEdit,
              icon: FontAwesomeIcons.signature,
              context: context,
              readOnly: true,
              onTap: onEndTime
          ),
        ]
    );
  }

}