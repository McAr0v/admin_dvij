import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../design/app_colors.dart';

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

    return jsonEncode(scheduleMap);
  }

  /// Вспомогательный метод для форматирования времени
  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Не выбрано'; // Возвращаем пустую строку, если времени нет
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Список дней недели
  final List<String> _days = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье'
  ];

  TimeOfDay? getTime({
    required int index,
    required bool isStart
  }) {
    switch (index) {
      case 0:
        return isStart ? mondayStart : mondayEnd;
      case 1:
        return isStart ? tuesdayStart : tuesdayEnd;
      case 2:
        return isStart ? wednesdayStart : wednesdayEnd;
      case 3:
        return isStart ? thursdayStart : thursdayEnd;
      case 4:
        return isStart ? fridayStart : fridayEnd;
      case 5:
        return isStart ? saturdayStart : saturdayEnd;
      case 6:
        return isStart ? sundayStart : sundayEnd;
      default:
        return null;
    }
  }

  bool checkRegularDate(){
    // Собираем все пары [start, end] в список
    final schedulePairs = [
      [mondayStart, mondayEnd],
      [tuesdayStart, tuesdayEnd],
      [wednesdayStart, wednesdayEnd],
      [thursdayStart, thursdayEnd],
      [fridayStart, fridayEnd],
      [saturdayStart, saturdayEnd],
      [sundayStart, sundayEnd],
    ];

    // Условие 1: Если нет ни одной даты (все null), вернуть false
    if (schedulePairs.every((pair) => pair[0] == null && pair[1] == null)) {
      return false;
    }

    // Условие 2: Если выбран start или end, но пары нет, вернуть false
    for (var pair in schedulePairs) {
      final start = pair[0];
      final end = pair[1];
      if ((start == null && end != null) || (start != null && end == null)) {
        return false;
      }
    }

    // Если оба условия выполнены, вернуть true
    return true;
  }

  Widget getRegularEditWidget({
    required BuildContext context,
    required Function(int index) onTapStart,
    required Function(int index) onTapEnd,
    required bool canEdit,
    required bool showSchedule,
    required VoidCallback show
  }){
    return GestureDetector(
      onTap: show,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Расписание', style: Theme.of(context).textTheme.titleMedium,)
              ),

              IconButton(
                  onPressed: show,
                  icon: Icon(
                      showSchedule == true ? FontAwesomeIcons.chevronDown : FontAwesomeIcons.chevronRight,
                    size: 15,
                  )
              )

            ],
          ),

          if (showSchedule) Column(
            children: List.generate(
              _days.length, // Количество элементов в списке
                  (index) => ListTile(
                contentPadding: EdgeInsets.zero,
                //title: Text(days[index]), // Получаем элемент по индексу
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [


                    Expanded(
                      flex: Platform.isMacOS || Platform.isWindows ? 1 : 2,
                      child: Text(
                        _days[index],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: canEdit ? () => onTapStart(index) : (){}, // Передаем индекс
                        child: Card(
                          color: AppColors.greyBackground,
                          child: Padding(
                            padding: EdgeInsets.all(Platform.isMacOS || Platform.isWindows ? 15.0 : 10),
                            child: Text(
                              'Начало: ${getTime(index: index, isStart: true)?.format(context) ?? 'Не выбрано'}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10,),

                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: canEdit ? () => onTapEnd(index) : (){}, // Передаем индекс
                        child: Card(
                          color: AppColors.greyBackground,
                          child: Padding(
                            padding: EdgeInsets.all(Platform.isMacOS || Platform.isWindows ? 15.0 : 10),
                            child: Text(
                              'Конец: ${getTime(index: index, isStart: false)?.format(context) ?? 'Не выбрано'}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}