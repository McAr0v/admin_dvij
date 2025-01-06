import 'dart:io';

import 'package:admin_dvij/categories/place_categories/place_category.dart';
import 'package:admin_dvij/constants/places_constants.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:admin_dvij/places/place_admin/place_admin_class.dart';
import 'package:admin_dvij/places/place_class.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../database/database_class.dart';
import '../design/app_colors.dart';
import '../design_elements/elements_of_design.dart';
import '../images/image_from_db.dart';
import '../images/image_location.dart';
import '../users/simple_users/simple_user.dart';

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

  Future<List<ImageFromDb>> searchUnusedImages({required List<ImageFromDb> imagesList}) async {

    if (_currentPlacesList.isEmpty) {
      await getListFromDb();
    }

    // Создаем Set с ID всех изображений, привязанных к мероприятиям
    Set<String> linkedImageIds = _currentPlacesList.map((entity) => entity.id).toSet();

    // Фильтруем список картинок, оставляя только те, которых нет в Set
    return imagesList.where((image) => !linkedImageIds.contains(image.id) && image.location.location == ImageLocationEnum.places ).toList();

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

  Widget getPlacesListWidget ({
    required List<Place> placesList,
    required VoidCallback onTap,
    required BuildContext context,
    required bool showPlaces,
    required void Function(int index) editPlace,
    required SimpleUser editUser
  }){
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: AppColors.greyBackground,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Заведения (${placesList.length})', style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                  ),
                  IconButton(
                      onPressed: onTap,
                      icon: Icon(showPlaces ? FontAwesomeIcons.chevronDown : FontAwesomeIcons.chevronRight, size: 15,)
                  )
                ],
              ),

              if (placesList.isNotEmpty && showPlaces) for (int i = 0; i < placesList.length; i++) Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: GestureDetector(
                  onTap: () => editPlace(i),
                  child: Card(
                    color: AppColors.greyOnBackground,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElementsOfDesign.imageWithTags(
                            imageUrl: placesList[i].imageUrl,
                            width: 100, //Platform.isWindows || Platform.isMacOS ? 100 : double.infinity,
                            height: 100,
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(placesList[i].name),
                                  Text(placesList[i].getAddress(), style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),),
                                  const SizedBox(height: 10),
                                  Text(
                                    placesList[i].getCurrentPlaceAdmin(adminsList: editUser.placesList).placeRole.toString(needTranslate: true),
                                    style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                  ),
                                ],
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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