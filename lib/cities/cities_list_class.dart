import 'dart:io';
import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/constants/city_constants.dart';
import 'package:admin_dvij/database/database_class.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:firebase_database/firebase_database.dart';

class CitiesList implements IEntitiesList<City>{

  CitiesList();

  // Переменная для сохранения с БД и предоставления доступа во
  // всем приложении
  static List<City> _allCitiesList = [];

  @override
  void setDownloadedList(List<City> list) {
    _allCitiesList = [];
    _allCitiesList = list;
  }

  @override
  List<City> searchElementInList(String query){
    List<City> citiesToReturn = _allCitiesList;

    citiesToReturn = citiesToReturn
        .where((client) =>
    client.name.toLowerCase().contains(query.toLowerCase())).toList();

    return citiesToReturn;
  }

  @override
  Future<List<City>> getDownloadedList({bool fromDb = false}) async {
    if (_allCitiesList.isEmpty || fromDb) {
      await getListFromDb();
    }
    return _allCitiesList;
  }

  @override
  Future<List<City>> getListFromDb() async {
    DatabaseClass database = DatabaseClass();

    const String path = CityConstants.citiesPath;

    List<City> tempCities = [];

    // Подгрузка если платформа не Windows
    if (!Platform.isWindows){
      DataSnapshot? snapshot = await database.getInfoFromDb(path);

      if (snapshot != null && snapshot.exists) {
        for(DataSnapshot city in snapshot.children) {
          City tempCity = City.fromSnapshot(snapshot: city);
          tempCities.add(tempCity);
        }
      }

    } else {

      // Подгрузка если Windows
      dynamic data = await database.getInfoFromDbForWindows(path);

      data.forEach((key, value) {

        tempCities.add(
            City.fromJson(json: value)
        );
      });

    }

    // Устанавливаем подгруженный список в нашу доступную переменную
    setDownloadedList(tempCities);

    // Сортируем список
    _allCitiesList.sortCities(true);

    return _allCitiesList;
  }

  @override
  bool checkEntityNameInList(String entityName) {
    if (_allCitiesList.any((element) => element.name.toLowerCase() == entityName.toLowerCase())) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void addToCurrentDownloadedList(City entity) {
    // Проверяем, есть ли элемент с таким id
    int index = _allCitiesList.indexWhere((c) => c.id == entity.id);

    if (index != -1) {
      // Если элемент с таким id уже существует, заменяем его
      _allCitiesList[index] = entity;
    } else {
      // Если элемет с таким id не найден, добавляем новый
      _allCitiesList.add(entity);
    }

    // Сортируем список
    _allCitiesList.sortCities(true);
  }

  @override
  void deleteEntityFromDownloadedList(String id) {
    if (_allCitiesList.isNotEmpty){
      _allCitiesList.removeWhere((city) => city.id == id);
    }
  }

  @override
  City getEntityFromList(String id){
    City returnedCity = City.empty();

    if (_allCitiesList.isNotEmpty){
      for (City city in _allCitiesList) {
        if (city.id == id) {
          returnedCity = city;
          break;
        }
      }
    }
    return returnedCity;
  }

}

extension SortCityListExtension on List<City> {

  void sortCities(bool order) {
    if (order) {
      sort((a, b) => a.name.compareTo(b.name));
    } else {
      sort((a, b) => b.name.compareTo(a.name));
    }
  }
}