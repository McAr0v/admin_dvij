import 'dart:io';
import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/constants/city_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/database/database_class.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:admin_dvij/logs/action_class.dart';
import 'package:admin_dvij/logs/entity_enum.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/database_constants.dart';
import '../constants/users_constants.dart';
import '../design_elements/elements_of_design.dart';
import '../logs/log_class.dart';


class City implements IEntity<City>{
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

  factory City.setCity({required City city}){
    return City(id: city.id, name: city.name);
  }

  Widget getCityWidget({
    required bool canEdit,
    required BuildContext context,
    required VoidCallback onTap
  }){

    TextEditingController cityController = TextEditingController();
    cityController.text = name.isNotEmpty ? name : CityConstants.cityNotChosen;

    return ElementsOfDesign.buildTextField(
        controller: cityController,
        labelText: UserConstants.city,
        canEdit: canEdit,
        icon: FontAwesomeIcons.mapLocation,
        context: context,
        readOnly: true,
        onTap: onTap
    );
  }

  @override
  Future<String> publishToDb(File? imageFile) async{

    DatabaseClass db = DatabaseClass();

    // Если Id не задан
    if (id == '') {
      // Генерируем ID
      String? idCity = db.generateKey();

      // Если ID по какой то причине не сгенерировался
      // генерируем вручную
      id = idCity ?? 'noId_$name';

      // Публикуем запись в логе, если создание
      await LogCustom.empty().createAndPublishLog(
          entityId: id,
          entityEnum: EntityEnum.city,
          actionEnum: ActionEnum.create,
          creatorId: ''
      );

    }

    String path = '${CityConstants.citiesPath}/$id';

    Map <String, dynamic> cityData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, cityData);

    } else {

      result = await db.publishToDBForWindows(path, cityData);

    }

    if (result == SystemConstants.successConst) {
      // Если результат успешный, добавляем в общий сохраненный список
      CitiesList citiesList = CitiesList();
      citiesList.addToCurrentDownloadedList(this);
    }

    return result;

  }

  @override
  Future<String> deleteFromDb() async {
    DatabaseClass db = DatabaseClass();

    String path = '${CityConstants.citiesPath}/$id/';

    String result = '';

    if (!Platform.isWindows){
      result =  await db.deleteFromDb(path);
    } else {
      result = await db.deleteFromDbForWindows(path);
    }

    if (result == SystemConstants.successConst) {
      // Если удаление прошло успешно, удаляем из общего списка
      CitiesList citiesList = CitiesList();
      citiesList.deleteEntityFromDownloadedList(id);
    }

    return result;

  }

  @override
  Map<String, dynamic> getMap (){
    return <String, dynamic> {
      DatabaseConstants.id: id,
      DatabaseConstants.name: name
    };
  }
  
}