import 'dart:io';

import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/constants/path_constants.dart';
import 'package:admin_dvij/database/database_class.dart';
import 'package:firebase_database/firebase_database.dart';

class CitiesList {

  CitiesList();

  static List<City> _allCitiesList = [];

  void setCitiesList (List<City> cities) {
    _allCitiesList = [];
    _allCitiesList = cities;
  }

  List<City> getListFromSearch(String query){
    List<City> citiesToReturn = _allCitiesList;


    citiesToReturn = citiesToReturn
        .where((client) =>
    client.name.toLowerCase().contains(query.toLowerCase())).toList();

    return citiesToReturn;
  }

  Future<List<City>> getCitiesList ({bool fromDb = false}) async{

    if (_allCitiesList.isEmpty || fromDb) {
      await getCitiesFromDb();
    }
    return _allCitiesList;
  }

  Future<List<City>> getCitiesFromDb () async {

    DatabaseClass database = DatabaseClass();

    const String path = PathConstants.citiesPath;

    List<City> tempCities = [];

    if (!Platform.isWindows){
      DataSnapshot? snapshot = await database.getInfoFromDb(path);

      if (snapshot != null && snapshot.exists) {
        for(DataSnapshot city in snapshot.children) {
          City tempCity = City.fromSnapshot(snapshot: city);
          tempCities.add(tempCity);
        }
      }

    } else {

      dynamic data = await database.getInfoFromDbForWindows(path);

      data.forEach((key, value) {
        tempCities.add(City(id: value['id'], name: value['name']));
      });

    }

    setCitiesList(tempCities);

    _allCitiesList.sortCities(true);

    return _allCitiesList;

  }

  bool checkCityNameInList(String cityName){

    if (_allCitiesList.any((element) => element.name.toLowerCase() == cityName.toLowerCase())) {
      return false;
    } else {
      return true;
    }
  }

  void addToCurrentList(City city){
    // Проверяем, есть ли город с таким id
    int index = _allCitiesList.indexWhere((c) => c.id == city.id);

    if (index != -1) {
      // Если город с таким id уже существует, заменяем его
      _allCitiesList[index] = city;
    } else {
      // Если город с таким id не найден, добавляем новый
      _allCitiesList.add(city);
    }

    _allCitiesList.sortCities(true);
  }

  void deleteCityFromCurrentList(String id) {
    if (_allCitiesList.isNotEmpty){
      _allCitiesList.removeWhere((city) => city.id == id);
    }
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