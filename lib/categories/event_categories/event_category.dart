import 'dart:io';
import 'package:admin_dvij/categories/event_categories/event_categories_list.dart';
import 'package:admin_dvij/constants/categories_constants.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../constants/database_constants.dart';
import '../../constants/system_constants.dart';
import '../../database/database_class.dart';

class EventCategory implements IEntity {
  String id;
  String name;

  EventCategory({required this.id, required this.name});

  factory EventCategory.fromSnapshot({required DataSnapshot snapshot}) {
    return EventCategory(
      id: snapshot.child(DatabaseConstants.id).value.toString(),
      name: snapshot.child(DatabaseConstants.name).value.toString(),
    );
  }

  factory EventCategory.fromJson({required Map<String, dynamic> json}){
    return EventCategory(
        id: json[DatabaseConstants.id] ?? '',
        name: json[DatabaseConstants.name] ?? ''
    );
  }

  factory EventCategory.empty(){
    return EventCategory(id: '', name: '');
  }

  @override
  Future<String> deleteFromDb() async{
    DatabaseClass db = DatabaseClass();

    String path = '${CategoriesConstants.eventCategoryPath}/$id/';

    String result = '';

    if (!Platform.isWindows){
      result =  await db.deleteFromDb(path);
    } else {
      result = await db.deleteFromDbForWindows(path);
    }

    if (result == SystemConstants.successConst) {
      // Если удаление прошло успешно, удаляем из общего списка
      EventCategoriesList eventsList = EventCategoriesList();
      eventsList.deleteEntityFromDownloadedList(id);

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
  Future<String> publishToDb(File? imageFile) async {
    DatabaseClass db = DatabaseClass();

    // Если Id не задан
    if (id == '') {
      // Генерируем ID
      String? idCategory = db.generateKey();

      // Если ID по какой то причине не сгенерировался
      // генерируем вручную
      id = idCategory ?? 'noId_$name';
    }

    String path = '${CategoriesConstants.eventCategoryPath}/$id';

    Map <String, dynamic> cityData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, cityData);

    } else {

      result = await db.publishToDBForWindows(path, cityData);

    }

    if (result == SystemConstants.successConst) {
      // Если результат успешный, добавляем в общий сохраненный список
      EventCategoriesList eventsList = EventCategoriesList();
      eventsList.addToCurrentDownloadedList(this);

    }

    return result;
  }



}