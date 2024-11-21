import 'dart:io';

import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/constants/path_constants.dart';
import 'package:admin_dvij/database/database_class.dart';
import 'package:firebase_database/firebase_database.dart';

class CitiesList {

  CitiesList();

  List<City> _allCitiesList = [];

  void setCitiesList (List<City> cities) {
    _allCitiesList = [];
    _allCitiesList = cities;
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

    return _allCitiesList;

  }



}