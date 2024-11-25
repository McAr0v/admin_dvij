import 'dart:io';
import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/constants/city_constants.dart';
import 'package:admin_dvij/database/database_class.dart';
import 'package:firebase_database/firebase_database.dart';

class CitiesList {

  CitiesList();

  // Переменная для сохранения с БД и предоставления доступа во
  // всем приложении
  static List<City> _allCitiesList = [];

  // Метод обновления списка из БД
  void setCitiesList (List<City> cities) {
    _allCitiesList = [];
    _allCitiesList = cities;
  }


  // Метод поиска сущностей по параметру
  List<City> searchElementInList(String query){
    List<City> citiesToReturn = _allCitiesList;

    citiesToReturn = citiesToReturn
        .where((client) =>
    client.name.toLowerCase().contains(query.toLowerCase())).toList();

    return citiesToReturn;
  }

  // Метод получения уже загруженного списка или подгрузки из БД
  Future<List<City>> getCitiesList ({bool fromDb = false}) async{

    if (_allCitiesList.isEmpty || fromDb) {
      await getCitiesFromDb();
    }
    return _allCitiesList;
  }

  // Метод подгрузки списка из БД
  Future<List<City>> getCitiesFromDb () async {

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
    setCitiesList(tempCities);

    // Сортируем список
    _allCitiesList.sortCities(true);

    return _allCitiesList;

  }

  // Проверка по имени, есть ли такое имя элемента в списке
  bool checkCityNameInList(String cityName){

    if (_allCitiesList.any((element) => element.name.toLowerCase() == cityName.toLowerCase())) {
      return false;
    } else {
      return true;
    }
  }

  // Добавление или редактирование в сохраненный общий список элемента
  void addToCurrentList(City city){

    // Проверяем, есть ли элемент с таким id
    int index = _allCitiesList.indexWhere((c) => c.id == city.id);

    if (index != -1) {
      // Если элемент с таким id уже существует, заменяем его
      _allCitiesList[index] = city;
    } else {
      // Если элемет с таким id не найден, добавляем новый
      _allCitiesList.add(city);
    }

    // Сортируем список
    _allCitiesList.sortCities(true);
  }

  // Удаление элемента из общего списка
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