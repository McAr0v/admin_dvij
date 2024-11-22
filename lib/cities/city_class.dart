import 'dart:io';
import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/constants/path_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/database/database_class.dart';
import 'package:firebase_database/firebase_database.dart';
import '../constants/database_constants.dart';


class City {
  String id;
  String name;
  
  City({required this.id, required this.name});
  
  factory City.fromSnapshot({required DataSnapshot snapshot}) {
    return City(
        id: snapshot.child(DatabaseConstants.id).value.toString(),
        name: snapshot.child(DatabaseConstants.name).value.toString(),
    );
  }

  factory City.fromJson({required Map<String, dynamic> json}){
    return City(
        id: json[DatabaseConstants.id] ?? '',
        name: json[DatabaseConstants.name] ?? ''
    );
  }

  factory City.empty(){
    return City(id: '', name: '');
  }

  Future<String> publishToDb() async{

    DatabaseClass db = DatabaseClass();

    if (id == '') {
      String? idCity = db.generateKey();
      id = idCity ?? 'noId_$name';
    }

    String path = '${PathConstants.citiesPath}/$id';

    Map <String, dynamic> cityData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, cityData);

    } else {

      result = await db.publishToDBForWindows(path, cityData);

    }

    if (result == SystemConstants.successConst) {
      CitiesList citiesList = CitiesList();
      citiesList.addToCurrentList(this);
    }

    return result;

  }

  Future<String> deleteFromDb() async {
    DatabaseClass db = DatabaseClass();

    String path = '${PathConstants.citiesPath}/$id/';

    String result = '';

    if (!Platform.isWindows){
      result =  await db.deleteFromDb(path);
    } else {
      result = await db.deleteFromDbForWindows(path);
    }

    if (result == SystemConstants.successConst) {
      CitiesList citiesList = CitiesList();
      citiesList.deleteCityFromCurrentList(id);
    }

    return result;

  }

  Map<String, dynamic> getMap (){
    return <String, dynamic> {
      DatabaseConstants.id: id,
      DatabaseConstants.name: name
    };
  }
  
}