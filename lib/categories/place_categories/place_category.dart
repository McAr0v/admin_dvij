import 'dart:io';

import 'package:admin_dvij/categories/place_categories/place_categories_list.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../constants/categories_constants.dart';
import '../../constants/database_constants.dart';
import '../../constants/system_constants.dart';
import '../../database/database_class.dart';
import '../../interfaces/entity_interface.dart';

class PlaceCategory implements IEntity {
  String id;
  String name;

  PlaceCategory({required this.name, required this.id});

  factory PlaceCategory.fromSnapshot({required DataSnapshot snapshot}) {
    return PlaceCategory(
      id: snapshot.child(DatabaseConstants.id).value.toString(),
      name: snapshot.child(DatabaseConstants.name).value.toString(),
    );
  }

  factory PlaceCategory.fromJson({required Map<String, dynamic> json}){
    return PlaceCategory(
        id: json[DatabaseConstants.id] ?? '',
        name: json[DatabaseConstants.name] ?? ''
    );
  }

  factory PlaceCategory.empty(){
    return PlaceCategory(id: '', name: '');
  }

  @override
  Future<String> deleteFromDb() async{
    DatabaseClass db = DatabaseClass();

    String path = '${CategoriesConstants.placeCategoryPath}/$id/';

    String result = '';

    if (!Platform.isWindows){
      result =  await db.deleteFromDb(path);
    } else {
      result = await db.deleteFromDbForWindows(path);
    }

    if (result == SystemConstants.successConst) {
      // Если удаление прошло успешно, удаляем из общего списка
      PlaceCategoriesList placesList = PlaceCategoriesList();
      placesList.deleteEntityFromDownloadedList(id);

    }

    return result;
  }

  @override
  Map<String, dynamic> getMap() {
    return <String, dynamic> {
      DatabaseConstants.id: id,
      DatabaseConstants.name: name
    };
  }

  @override
  Future<String> publishToDb(File? imageFile) async{
    DatabaseClass db = DatabaseClass();

    // Если Id не задан
    if (id == '') {
      // Генерируем ID
      String? idCategory = db.generateKey();

      // Если ID по какой то причине не сгенерировался
      // генерируем вручную
      id = idCategory ?? 'noId_$name';
    }

    String path = '${CategoriesConstants.placeCategoryPath}/$id';

    Map <String, dynamic> categoryData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, categoryData);

    } else {

      result = await db.publishToDBForWindows(path, categoryData);

    }

    if (result == SystemConstants.successConst) {
      // Если результат успешный, добавляем в общий сохраненный список
      PlaceCategoriesList placesList = PlaceCategoriesList();
      placesList.addToCurrentDownloadedList(this);
    }
    return result;
  }
}