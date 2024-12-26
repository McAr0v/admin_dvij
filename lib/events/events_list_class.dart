import 'dart:io';

import 'package:admin_dvij/constants/events_constants.dart';
import 'package:admin_dvij/events/event_class.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:firebase_database/firebase_database.dart';

import '../categories/event_categories/event_category.dart';
import '../cities/city_class.dart';
import '../database/database_class.dart';

class EventsListClass implements IEntitiesList<EventClass> {

  static List<EventClass> _currentEventsList = [];


  @override
  void addToCurrentDownloadedList(EventClass entity) {
    // Проверяем, есть ли элемент с таким id
    int index = _currentEventsList.indexWhere((c) => c.id == entity.id);

    if (index != -1) {
      // Если элемент с таким id уже существует, заменяем его
      _currentEventsList[index] = entity;
    } else {
      // Если элемет с таким id не найден, добавляем новый
      _currentEventsList.add(entity);
    }

    _currentEventsList.sortEvents(true);
  }

  @override
  bool checkEntityNameInList(String entity) {
    if (_currentEventsList.any((element) => element.id.toLowerCase() == entity.toLowerCase())) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void deleteEntityFromDownloadedList(String id) {
    if (_currentEventsList.isNotEmpty){
      _currentEventsList.removeWhere((event) => event.id == id);
    }
  }

  @override
  Future<List<EventClass>> getDownloadedList({bool fromDb = false}) async{
    if (_currentEventsList.isEmpty || fromDb) {
      await getListFromDb();
    }
    return _currentEventsList;
  }

  @override
  EventClass getEntityFromList(String id) {
    EventClass returnedEvent = EventClass.empty();

    if (_currentEventsList.isNotEmpty) {
      for (EventClass event in _currentEventsList) {
        if (event.id == id) {
          returnedEvent = event;
          break;
        }
      }
    }
    return returnedEvent;
  }

  @override
  Future<List<EventClass>> getListFromDb() async{
    DatabaseClass database = DatabaseClass();

    const String path = EventsConstants.eventsPath;

    List<EventClass> tempList = [];

    // Подгрузка если платформа не Windows
    if (!Platform.isWindows){
      DataSnapshot? snapshot = await database.getInfoFromDb(path);

      if (snapshot != null && snapshot.exists) {
        for(DataSnapshot idFolder in snapshot.children){
          EventClass tempEntity = EventClass.fromSnapshot(snapshot: idFolder);
          tempList.add(tempEntity);
        }
      }

    } else {

      // Подгрузка если Windows

      dynamic data = await database.getInfoFromDbForWindows(path);

      if (data != null){
        data.forEach((key, idFolders) {
          tempList.add(EventClass.fromJson(json: idFolders));
        });
      }
    }

    // Устанавливаем подгруженный список в нашу доступную переменную
    setDownloadedList(tempList);

    // Сортируем список

    _currentEventsList.sortEvents(true);

    return _currentEventsList;
  }

  @override
  List<EventClass> searchElementInList(String query) {
    List<EventClass> eventsToReturn = _currentEventsList;

    eventsToReturn = eventsToReturn
        .where((place) =>
    place.headline.toLowerCase().contains(query.toLowerCase())
        || place.desc.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return eventsToReturn;
  }

  @override
  void setDownloadedList(List<EventClass> list) {
    _currentEventsList = [];
    _currentEventsList = list;
  }

  Future<List<EventClass>> getNeededEvents({
    bool fromDb = false,
    required City filterCity,
    required EventCategory filterCategory,
    required bool filterInPlace,
    required String searchingText,
    required bool isActive
  }) async {

    List<EventClass> returnedList = [];

    if (_currentEventsList.isEmpty || fromDb){
      await getListFromDb();
    }

    for (EventClass tempEvent in _currentEventsList){

      // Если нужен список активных
      if(isActive){

        // Если активное
        if (!tempEvent.isFinished()){

          // Проверяем на совпадение значениям фильтра
          if (checkEventOnFilter(
              filterCity: filterCity,
              filterCategory: filterCategory,
              filterInPlace: filterInPlace,
              tempEvent: tempEvent)
          ){
            returnedList.add(tempEvent);
          }
        }
      }
      // Если нужен список завершенных
      else {

        // Если завершено
        if (tempEvent.isFinished()){

          // Проверяем на совпадение значениям фильтра
          if (checkEventOnFilter(
              filterCity: filterCity,
              filterCategory: filterCategory,
              filterInPlace: filterInPlace,
              tempEvent: tempEvent)
          ){
            returnedList.add(tempEvent);
          }
        }
      }
    }

    if (searchingText.isNotEmpty){
      returnedList = returnedList
          .where((event) =>
      event.headline.toLowerCase().contains(searchingText.toLowerCase()) ||
          event.desc.toLowerCase().contains(searchingText.toLowerCase()) ||
          event.city.name.toLowerCase().contains(searchingText.toLowerCase()) ||
          event.category.name.toLowerCase().contains(searchingText.toLowerCase()) ||
          event.street.toLowerCase().contains(searchingText.toLowerCase())
      ).toList();
    }

    return returnedList;

  }

  bool checkEventOnFilter({
    required City filterCity,
    required EventCategory filterCategory,
    required bool filterInPlace,
    required EventClass tempEvent,
  }) {
    // Проверка города
    final bool cityMatches = filterCity.id.isEmpty || tempEvent.city.id == filterCity.id;

    // Проверка категории
    final bool categoryMatches = filterCategory.id.isEmpty || tempEvent.category.id == filterCategory.id;

    // Проверка на то, находится ли событие в заведении
    final bool inPlaceMatches = !filterInPlace || tempEvent.placeId.isNotEmpty;

    // Если все фильтры соответствуют, возвращаем true
    return cityMatches && categoryMatches && inPlaceMatches;
  }

}

extension SortEventsListExtension on List<EventClass> {

  void sortEvents(bool order) {
    if (order) {
      sort((a, b) => a.createDate.compareTo(b.createDate));
    } else {
      sort((a, b) => b.createDate.compareTo(a.createDate));
    }
  }

}