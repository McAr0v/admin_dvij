import 'dart:io';
import 'package:admin_dvij/categories/place_categories/place_category.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../constants/categories_constants.dart';
import '../../database/database_class.dart';

class PlaceCategoriesList implements IEntitiesList<PlaceCategory>{

  PlaceCategoriesList();

  static List<PlaceCategory> _currentPlaceCategoriesList = [];

  @override
  void addToCurrentDownloadedList(PlaceCategory entity) {
    // Проверяем, есть ли элемент с таким id
    int index = _currentPlaceCategoriesList.indexWhere((c) => c.id == entity.id);

    if (index != -1) {
      // Если элемент с таким id уже существует, заменяем его
      _currentPlaceCategoriesList[index] = entity;
    } else {
      // Если элемет с таким id не найден, добавляем новый
      _currentPlaceCategoriesList.add(entity);
    }

    // Сортируем список
    _currentPlaceCategoriesList.sortPlaceCategories(true);
  }

  @override
  bool checkEntityNameInList(String entity) {
    if (_currentPlaceCategoriesList.any((element) => element.name.toLowerCase() == entity.toLowerCase())) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void deleteEntityFromDownloadedList(String id) {
    if (_currentPlaceCategoriesList.isNotEmpty){
      _currentPlaceCategoriesList.removeWhere((category) => category.id == id);
    }
  }

  @override
  Future<List<PlaceCategory>> getDownloadedList({bool fromDb = false}) async{
    if (_currentPlaceCategoriesList.isEmpty || fromDb) {
      await getListFromDb();
    }
    return _currentPlaceCategoriesList;
  }

  @override
  PlaceCategory getEntityFromList(String id) {
    PlaceCategory returnedCategory = PlaceCategory.empty();

    if (_currentPlaceCategoriesList.isNotEmpty){
      for (PlaceCategory category in _currentPlaceCategoriesList) {
        if (category.id == id) {
          returnedCategory = category;
          break;
        }
      }
    }
    return returnedCategory;
  }

  @override
  Future<List<PlaceCategory>> getListFromDb() async{
    DatabaseClass database = DatabaseClass();

    String path = CategoriesConstants.placeCategoryPath;

    List<PlaceCategory> tempCategories = [];

    // Подгрузка если платформа не Windows
    if (!Platform.isWindows){
      DataSnapshot? snapshot = await database.getInfoFromDb(path);

      if (snapshot != null && snapshot.exists) {
        for(DataSnapshot category in snapshot.children) {
          PlaceCategory tempCategory = PlaceCategory.fromSnapshot(snapshot: category);
          tempCategories.add(tempCategory);
        }
      }

    } else {

      // Подгрузка если Windows
      dynamic data = await database.getInfoFromDbForWindows(path);

      data.forEach((key, value) {

        tempCategories.add(
            PlaceCategory.fromJson(json: value)
        );
      });

    }

    // Устанавливаем подгруженный список в нашу доступную переменную
    setDownloadedList(tempCategories);

    // Сортируем список
    _currentPlaceCategoriesList.sortPlaceCategories(true);

    return _currentPlaceCategoriesList;
  }

  @override
  List<PlaceCategory> searchElementInList(String query) {
    List<PlaceCategory> categoriesToReturn = _currentPlaceCategoriesList;

    categoriesToReturn = categoriesToReturn
        .where((client) =>
        client.name.toLowerCase().contains(query.toLowerCase())).toList();

    return categoriesToReturn;
  }

  @override
  void setDownloadedList(List<PlaceCategory> list) {
    _currentPlaceCategoriesList = [];
    _currentPlaceCategoriesList = list;
  }
}

extension SortPlaceCategoryListExtension on List<PlaceCategory> {

  void sortPlaceCategories(bool order) {
    if (order) {
      sort((a, b) => a.name.compareTo(b.name));
    } else {
      sort((a, b) => b.name.compareTo(a.name));
    }
  }
}