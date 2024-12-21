import 'dart:convert';
import 'dart:io';
import 'package:admin_dvij/constants/regular_date_constants.dart';
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
      mondayStart: parseTime(jsonData[RegularDateConstants.startTime1Id]),
      mondayEnd: parseTime(jsonData[RegularDateConstants.endTime1Id]),
      tuesdayStart: parseTime(jsonData[RegularDateConstants.startTime2Id]),
      tuesdayEnd: parseTime(jsonData[RegularDateConstants.endTime2Id]),
      wednesdayStart: parseTime(jsonData[RegularDateConstants.startTime3Id]),
      wednesdayEnd: parseTime(jsonData[RegularDateConstants.endTime3Id]),
      thursdayStart: parseTime(jsonData[RegularDateConstants.startTime4Id]),
      thursdayEnd: parseTime(jsonData[RegularDateConstants.endTime4Id]),
      fridayStart: parseTime(jsonData[RegularDateConstants.startTime5Id]),
      fridayEnd: parseTime(jsonData[RegularDateConstants.endTime5Id]),
      saturdayStart: parseTime(jsonData[RegularDateConstants.startTime6Id]),
      saturdayEnd: parseTime(jsonData[RegularDateConstants.endTime6Id]),
      sundayStart: parseTime(jsonData[RegularDateConstants.startTime7Id]),
      sundayEnd: parseTime(jsonData[RegularDateConstants.endTime7Id]),
    );
  }

  /// Метод для преобразования в строку JSON
  String toJsonString() {
    final Map<String, String> scheduleMap = {
      RegularDateConstants.startTime1Id: _formatTime(mondayStart),
      RegularDateConstants.endTime1Id: _formatTime(mondayEnd),
      RegularDateConstants.startTime2Id: _formatTime(tuesdayStart),
      RegularDateConstants.endTime2Id: _formatTime(tuesdayEnd),
      RegularDateConstants.startTime3Id: _formatTime(wednesdayStart),
      RegularDateConstants.endTime3Id: _formatTime(wednesdayEnd),
      RegularDateConstants.startTime4Id: _formatTime(thursdayStart),
      RegularDateConstants.endTime4Id: _formatTime(thursdayEnd),
      RegularDateConstants.startTime5Id: _formatTime(fridayStart),
      RegularDateConstants.endTime5Id: _formatTime(fridayEnd),
      RegularDateConstants.startTime6Id: _formatTime(saturdayStart),
      RegularDateConstants.endTime6Id: _formatTime(saturdayEnd),
      RegularDateConstants.startTime7Id: _formatTime(sundayStart),
      RegularDateConstants.endTime7Id: _formatTime(sundayEnd),
    };

    return jsonEncode(scheduleMap);
  }

  /// Вспомогательный метод для форматирования времени
  String _formatTime(TimeOfDay? time) {
    if (time == null) return RegularDateConstants.notChosen; // Возвращаем пустую строку, если времени нет
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Список дней недели
  final List<String> _days = [
    RegularDateConstants.monday,
    RegularDateConstants.tuesday,
    RegularDateConstants.wednesday,
    RegularDateConstants.thursday,
    RegularDateConstants.friday,
    RegularDateConstants.saturday,
    RegularDateConstants.sunday
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
    required Function(int index) onClean,
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
                  child: Text(RegularDateConstants.scheduleHeadline, style: Theme.of(context).textTheme.titleMedium,)
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

                    if (
                        getTime(index: index, isStart: true) != null
                        && getTime(index: index, isStart: false) != null && canEdit
                    ) IconButton(
                        onPressed: canEdit ? () => onClean(index) : (){},
                        icon: const Icon(FontAwesomeIcons.x, size: 15,)
                    ),

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
                              '${RegularDateConstants.startHeadline}: ${getTime(index: index, isStart: true)?.format(context) ?? RegularDateConstants.notChosen}',
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
                              '${RegularDateConstants.endHeadline}: ${getTime(index: index, isStart: false)?.format(context) ?? RegularDateConstants.notChosen}',
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