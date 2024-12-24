import 'dart:io';

import 'package:admin_dvij/categories/place_categories/place_category.dart';
import 'package:admin_dvij/constants/places_constants.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:admin_dvij/places/place_admin/place_admin_class.dart';
import 'package:admin_dvij/places/place_class.dart';
import 'package:firebase_database/firebase_database.dart';

import '../database/database_class.dart';

class PlacesList implements IEntitiesList<Place>{

  static List<Place> _currentPlacesList = [];

  @override
  void addToCurrentDownloadedList(Place entity) {
    // Проверяем, есть ли элемент с таким id
    int index = _currentPlacesList.indexWhere((c) => c.id == entity.id);

    if (index != -1) {
      // Если элемент с таким id уже существует, заменяем его
      _currentPlacesList[index] = entity;
    } else {
      // Если элемет с таким id не найден, добавляем новый
      _currentPlacesList.add(entity);
    }

    _currentPlacesList.sortPlaces(true);
  }



  @override
  bool checkEntityNameInList(String entity) {
    if (_currentPlacesList.any((element) => element.id.toLowerCase() == entity.toLowerCase())) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void deleteEntityFromDownloadedList(String id) {
    if (_currentPlacesList.isNotEmpty){
      _currentPlacesList.removeWhere((place) => place.id == id);
    }
  }

  @override
  Future<List<Place>> getDownloadedList({bool fromDb = false}) async {
    if (_currentPlacesList.isEmpty || fromDb) {
      await getListFromDb();
    }
    return _currentPlacesList;
  }

  @override
  Place getEntityFromList(String id) {
    Place returnedPlace = Place.empty();

    if (_currentPlacesList.isNotEmpty) {
      for (Place place in _currentPlacesList) {
        if (place.id == id) {
          returnedPlace = place;
          break;
        }
      }
    }
    return returnedPlace;
  }

  @override
  Future<List<Place>> getListFromDb() async {
    DatabaseClass database = DatabaseClass();

    const String path = PlacesConstants.placesPath;

    List<Place> tempPlaces = [];

    // Подгрузка если платформа не Windows
    if (!Platform.isWindows){
      DataSnapshot? snapshot = await database.getInfoFromDb(path);

      if (snapshot != null && snapshot.exists) {
        for(DataSnapshot idFolder in snapshot.children){
          Place tempPlace = Place.fromSnapshot(snapshot: idFolder);
          tempPlaces.add(tempPlace);
        }
      }

    } else {

      // Подгрузка если Windows

      dynamic data = await database.getInfoFromDbForWindows(path);

      if (data != null){
        data.forEach((key, idFolders) {
          tempPlaces.add(Place.fromJson(json: idFolders));
        });
      }
    }

    // Устанавливаем подгруженный список в нашу доступную переменную
    setDownloadedList(tempPlaces);

    // Сортируем список

    _currentPlacesList.sortPlaces(true);

    return _currentPlacesList;
  }

  @override
  List<Place> searchElementInList(String query) {
    List<Place> placesToReturn = _currentPlacesList;

    placesToReturn = placesToReturn
        .where((place) =>
    place.name.toLowerCase().contains(query.toLowerCase())
        || place.desc.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return placesToReturn;
  }

  @override
  void setDownloadedList(List<Place> list) {
    _currentPlacesList = [];
    _currentPlacesList = list;
  }

  Future<List<Place>> getNeededPlaces({
    bool fromDb = false,
    required PlaceCategory category,
    required bool filterHaveEvents,
    required bool filterHavePromos,
    String searchingText = ''
  }) async {

    List<Place> tempList = [];

    if (_currentPlacesList.isEmpty || fromDb){
      await getListFromDb();
    }

    for (Place place in _currentPlacesList){
      // Если категория не выбрана
      if (category.id.isEmpty){

        if (_checkFilterHaveEventsOrPromos(
            filterHaveEvents: filterHaveEvents,
            filterHavePromos: filterHavePromos,
            place: place)
        ) {
          tempList.add(place);
        }

      }
      // Если выбрана категория
      else if (place.category.id == category.id){
        if (_checkFilterHaveEventsOrPromos(
            filterHaveEvents: filterHaveEvents,
            filterHavePromos: filterHavePromos,
            place: place)
        ) {
          tempList.add(place);
        }
      }
    }

    if (searchingText.isNotEmpty){
      tempList = tempList
          .where((place) =>
      place.name.toLowerCase().contains(searchingText.toLowerCase()) ||
          place.desc.toLowerCase().contains(searchingText.toLowerCase()) ||
          place.category.name.toLowerCase().contains(searchingText.toLowerCase()) ||
          place.city.name.toLowerCase().contains(searchingText.toLowerCase()) ||
          place.getAddress().toLowerCase().contains(searchingText.toLowerCase())
      ).toList();
    }

    return tempList;
  }

  bool _checkFilterHaveEventsOrPromos({
    required bool filterHaveEvents,
    required bool filterHavePromos,
    required Place place
  }){
    // Если не выбранны флажки на "Есть мероприятия" и "Есть акции"
    if (!filterHaveEvents && !filterHavePromos){
      return true;
    }
    // Если выбраны флажки и на "Есть мероприятия" и на "есть акции"
    else if (filterHaveEvents && filterHavePromos){
      if (place.haveEventsOrPromos(isEvent: true) && place.haveEventsOrPromos(isEvent: false)){
        return true;
      }
    }
    // Если выбран только флажок "Есть акции"
    else if (!filterHaveEvents && filterHavePromos){
      if (place.haveEventsOrPromos(isEvent: false)){
        return true;
      }
    }

    // Если выбран только флажок "Есть мероприятия"
    else if (filterHaveEvents && !filterHavePromos){
      if (place.haveEventsOrPromos(isEvent: true)){
        return true;
      }
    }
    return false;
  }

  Future<List<Place>> getPlacesListFromSimpleUser({required List<PlaceAdmin> placesList}) async{

    List<Place> returnedList = [];

    if (_currentPlacesList.isEmpty){
      await getListFromDb();
    }

    for (PlaceAdmin place in placesList){
      Place tempPlace = getEntityFromList(place.placeId);
      if (tempPlace.id == place.placeId){
        returnedList.add(tempPlace);
      }
    }

    return returnedList;

  }



}

extension SortPlacesListExtension on List<Place> {

  void sortPlaces(bool order) {
    if (order) {
      sort((a, b) => a.createDate.compareTo(b.createDate));
    } else {
      sort((a, b) => b.createDate.compareTo(a.createDate));
    }
  }

}