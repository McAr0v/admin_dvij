import 'dart:convert';
import 'package:admin_dvij/constants/date_constants.dart';
import 'package:admin_dvij/constants/fields_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/system_methods/dates_methods.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../design_elements/elements_of_design.dart';

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

  factory OnceDate.setOnceDay({required OnceDate fromDate}){
    OnceDate onceDate = OnceDate.empty();

    onceDate.date = fromDate.date;
    onceDate.startTime = fromDate.startTime;
    onceDate.endTime = fromDate.endTime;

    return onceDate;
  }

  factory OnceDate.fromJson({required String jsonString}){

    if (jsonString.isNotEmpty){
      // Декодируем JSON-строку
      final Map<String, dynamic> json = jsonDecode(jsonString);

      // Извлекаем данные и создаем экземпляр
      final date = DateTime.parse(json[DateConstants.onceDayDateId]);
      final startTimeParts = json[DateConstants.startTimeId].split(':').map(int.parse).toList();
      final endTimeParts = json[DateConstants.endTimeId].split(':').map(int.parse).toList();

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
        DateConstants.onceDayDateId: date!.toIso8601String().split('T').first, // Только дата
        DateConstants.startTimeId: '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
        DateConstants.endTimeId: '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
      };

      // Возвращаем строку в формате JSON
      return jsonEncode(json);
    } else {
      return '';
    }
  }

  String checkDate(){
    if (date == null){
      return DateConstants.onceDayDateNoChosen;
    } else if (startTime == null){
      return DateConstants.startTimeNoChosen;
    } else if (endTime == null){
      return DateConstants.endTimeNoChosen;
    } else {
      return SystemConstants.successConst;
    }
  }

  /// Возвращает дату в формате: 1 января 2025 года
  String getHumanViewDate() {

    SystemMethodsClass sm = SystemMethodsClass();

    if (date != null){
      return sm.formatDateTimeToHumanView(date!);
    } else {
      return DateConstants.onceDayDateNoChosen;
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

  Widget getOnceDayWidget({
    required bool isMobile,
    required bool canEdit,
    bool isIrregular = false,
    required BuildContext context,
    required VoidCallback onDateTap,
    required VoidCallback onStartTimeTap,
    required VoidCallback onEndTimeTap,
    VoidCallback? onRemoveDate,
  }){

    SystemMethodsClass sm = SystemMethodsClass();

    TextEditingController dateController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();

    dateController.text = date != null ? sm.formatDateTimeToHumanView(date!) : DateConstants.onceDayDateChoose;
    startTimeController.text = startTime != null ? sm.formatTimeToHumanView(startTime!) : DateConstants.startTimeChoose;
    endTimeController.text = endTime != null ? sm.formatTimeToHumanView(endTime!) : DateConstants.endTimeChoose;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElementsOfDesign.buildAdaptiveRow(
          isMobile: isMobile,
          children: [
            Row(
              children: [

                if (isIrregular && canEdit && !isMobile) ElementsOfDesign.cleanButton(onClean: onRemoveDate ?? (){}),

                if (isIrregular && canEdit && !isMobile) const SizedBox(width: 10,),

                Expanded(
                  child: ElementsOfDesign.buildTextField(
                      controller: dateController,
                      labelText: FieldsConstants.dateField,
                      canEdit: canEdit,
                      icon: FontAwesomeIcons.calendar,
                      context: context,
                      readOnly: true,
                      onTap: onDateTap
                  ),
                ),

                if (isIrregular && canEdit && isMobile) const SizedBox(width: 10,),

                if (isIrregular && canEdit && isMobile) ElementsOfDesign.cleanButton(onClean: onRemoveDate ?? (){}),

              ],
            ),
            ElementsOfDesign.buildTextField(
                controller: startTimeController,
                labelText: FieldsConstants.startTimeField,
                canEdit: canEdit,
                icon: FontAwesomeIcons.clock,
                context: context,
                readOnly: true,
                onTap: onStartTimeTap
            ),
            ElementsOfDesign.buildTextField(
                controller: endTimeController,
                labelText: FieldsConstants.endTimeField,
                canEdit: canEdit,
                icon: FontAwesomeIcons.clock,
                context: context,
                readOnly: true,
                onTap: onEndTimeTap
            ),
          ]
      ),
    );
  }

}