import 'dart:io';
import 'package:admin_dvij/constants/database_constants.dart';
import 'package:admin_dvij/logs/log_class.dart';
import 'package:firebase_database/firebase_database.dart';
import '../database/database_class.dart';
import '../users/admin_user/admin_user_class.dart';
import 'action_class.dart';
import 'entity_enum.dart';

class LogListClass {

  static List<LogCustom> _currentLogList = [];

  void setDownloadedList(List<LogCustom> list) {
    _currentLogList = [];
    _currentLogList = list;
  }



  Future<List<LogCustom>> getDownloadedList({bool fromDb = false}) async {
    if (_currentLogList.isEmpty || fromDb) {
      await getListFromDb();
    }
    return _currentLogList;
  }

  Future<List<LogCustom>> getNeededLogs({
    bool fromDb = false,
    required LogEntity entity,
    required String searchingText,
  }) async {

    List<LogCustom> returnedList = [];

    if (_currentLogList.isEmpty || fromDb){
      await getListFromDb();
    }

    for (LogCustom log in _currentLogList){
      if (entity.entity == EntityEnum.notChosen) {
        returnedList.add(log);
      } else {
        if (entity.entity == log.entity.entity){
          returnedList.add(log);
        }
      }
    }

    if (searchingText.isNotEmpty){
      returnedList = returnedList
          .where((log) =>
      log.id.toLowerCase().contains(searchingText.toLowerCase()) ||
          log.creatorId.toLowerCase().contains(searchingText.toLowerCase()) ||
          log.getCreatorName().toLowerCase().contains(searchingText.toLowerCase()) ||
          log.entity.getEntityName(id: log.id).toLowerCase().contains(searchingText.toLowerCase()) ||
          log.action.toString(translate: true).toLowerCase().contains(searchingText.toLowerCase()) ||
          log.entity.toString(translate: true).toLowerCase().contains(searchingText.toLowerCase())
      ).toList();
    }

    return returnedList;

  }


  Future<List<LogCustom>> getListFromDb() async {
    DatabaseClass database = DatabaseClass();

    const String path = DatabaseConstants.logs;

    List<LogCustom> tempLogs = [];

    // Подгрузка если платформа не Windows
    if (!Platform.isWindows){
      DataSnapshot? snapshot = await database.getInfoFromDb(path);

      if (snapshot != null && snapshot.exists) {
        for(DataSnapshot yearFolder in snapshot.children) {
          for(DataSnapshot monthFolder in yearFolder.children) {
            for(DataSnapshot dayFolder in monthFolder.children) {
              for(DataSnapshot idFolder in dayFolder.children) {
                LogCustom tempLog = LogCustom.fromSnapshot(snapshot: idFolder);
                if (tempLog.id.isNotEmpty){
                  tempLogs.add(tempLog);
                }
              }
            }
          }
        }
      }
    } else {

      // Подгрузка если Windows
      dynamic data = await database.getInfoFromDbForWindows(path);

      print(data);

      if (data is Map<String, dynamic>) {
        data.forEach((year, yearFolder) {
          if (yearFolder is Map<String, dynamic>) { // ✅ Исправлено: это Map, а не List
            yearFolder.forEach((month, monthFolder) {
              if (monthFolder is Map<String, dynamic>) {
                monthFolder.forEach((day, dayFolder) {
                  if (dayFolder is Map<String, dynamic>) {
                    dayFolder.forEach((id, logData) {
                      if (logData is Map<String, dynamic>) {
                        tempLogs.add(LogCustom.fromJson(json: logData));
                      }
                    });
                  }
                });
              }
            });
          }
        });
      } else {
        print("❌ Ошибка: данные не являются Map<String, dynamic>");
      }
    }

    // Устанавливаем подгруженный список в нашу доступную переменную
    setDownloadedList(tempLogs);

    // Сортируем список
    _currentLogList.sortLogs(true);

    return _currentLogList;
  }

  void addToCurrentDownloadedList(LogCustom entity) {
    // Проверяем, есть ли элемент с таким id
    int index = _currentLogList.indexWhere((c) => c.id == entity.id);

    if (index != -1) {
      // Если элемент с таким id уже существует, заменяем его
      _currentLogList[index] = entity;
    } else {
      // Если элемет с таким id не найден, добавляем новый
      _currentLogList.add(entity);
    }

    // Сортируем список
    _currentLogList.sortLogs(true);
  }

  LogCustom getEntityFromList(String id) {
    LogCustom returnedLog = LogCustom.empty();

    if (_currentLogList.isNotEmpty){
      for (LogCustom log in _currentLogList) {
        if (log.id == id) {
          returnedLog = log;
          break;
        }
      }
    }
    return returnedLog;
  }

}

extension SortPoliciesListExtension on List<LogCustom> {

  void sortLogs(bool order) {
    if (order) {
      sort((a, b) => a.date.compareTo(b.date));
    } else {
      sort((a, b) => b.date.compareTo(a.date));
    }
  }

}