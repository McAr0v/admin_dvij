import 'dart:io';
import 'package:admin_dvij/categories/event_categories/event_category.dart';
import 'package:admin_dvij/constants/categories_constants.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../database/database_class.dart';

class EventCategoriesList implements IEntitiesList<EventCategory>{
  EventCategoriesList();

  static List<EventCategory> _allEventCategoriesList = [];

  @override
  void addToCurrentDownloadedList(EventCategory entity) {
    // Проверяем, есть ли элемент с таким id
    int index = _allEventCategoriesList.indexWhere((c) => c.id == entity.id);

    if (index != -1) {
      // Если элемент с таким id уже существует, заменяем его
      _allEventCategoriesList[index] = entity;
    } else {
      // Если элемет с таким id не найден, добавляем новый
      _allEventCategoriesList.add(entity);
    }

    // Сортируем список
    _allEventCategoriesList.sortEventCategories(true);
  }

  @override
  bool checkEntityNameInList(String entity) {
    if (_allEventCategoriesList.any((element) => element.name.toLowerCase() == entity.toLowerCase())) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void deleteEntityFromDownloadedList(String id) {
    if (_allEventCategoriesList.isNotEmpty){
      _allEventCategoriesList.removeWhere((category) => category.id == id);
    }
  }

  @override
  Future<List<EventCategory>> getDownloadedList({bool fromDb = false}) async{
    if (_allEventCategoriesList.isEmpty || fromDb) {
      await getListFromDb();
    }
    return _allEventCategoriesList;
  }

  @override
  EventCategory getEntityFromList(String id) {
    EventCategory returnedCategory = EventCategory.empty();

    if (_allEventCategoriesList.isNotEmpty){
      for (EventCategory category in _allEventCategoriesList) {
        if (category.id == id) {
          returnedCategory = category;
          break;
        }
      }
    }
    return returnedCategory;
  }

  @override
  Future<List<EventCategory>> getListFromDb() async{
    DatabaseClass database = DatabaseClass();

    const String path = CategoriesConstants.eventCategoryPath;

    List<EventCategory> tempCategories = [];

    // Подгрузка если платформа не Windows
    if (!Platform.isWindows){
      DataSnapshot? snapshot = await database.getInfoFromDb(path);

      if (snapshot != null && snapshot.exists) {
        for(DataSnapshot category in snapshot.children) {
          EventCategory tempCategory = EventCategory.fromSnapshot(snapshot: category);
          tempCategories.add(tempCategory);
        }
      }

    } else {

      // Подгрузка если Windows
      dynamic data = await database.getInfoFromDbForWindows(path);

      if (data != null){
        data.forEach((key, value) {

          tempCategories.add(
              EventCategory.fromJson(json: value)
          );
        });
      }
    }

    // Устанавливаем подгруженный список в нашу доступную переменную
    setDownloadedList(tempCategories);

    // Сортируем список
    _allEventCategoriesList.sortEventCategories(true);

    return _allEventCategoriesList;
  }

  @override
  List<EventCategory> searchElementInList(String query) {
    List<EventCategory> categoriesToReturn = _allEventCategoriesList;

    categoriesToReturn = categoriesToReturn
        .where((client) =>
        client.name.toLowerCase().contains(query.toLowerCase())).toList();

    return categoriesToReturn;
  }

  @override
  void setDownloadedList(List<EventCategory> list) {
    _allEventCategoriesList = [];
    _allEventCategoriesList = list;
  }
}

extension SortEventCategoryListExtension on List<EventCategory> {

  void sortEventCategories(bool order) {
    if (order) {
      sort((a, b) => a.name.compareTo(b.name));
    } else {
      sort((a, b) => b.name.compareTo(a.name));
    }
  }
}