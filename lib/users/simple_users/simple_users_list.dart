import 'dart:io';
import 'package:admin_dvij/constants/simple_users_constants.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:admin_dvij/places/place_admin/place_admin_class.dart';
import 'package:admin_dvij/users/simple_users/simple_user.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../database/database_class.dart';
import '../../images/image_from_db.dart';
import '../../images/image_location.dart';

class SimpleUsersList implements IEntitiesList<SimpleUser>{

  SimpleUsersList();

  static List<SimpleUser> _currentSimpleUsersList = [];

  @override
  void addToCurrentDownloadedList(SimpleUser entity) {
    // Проверяем, есть ли элемент с таким id
    int index = _currentSimpleUsersList.indexWhere((c) => c.uid == entity.uid);

    if (index != -1) {
      // Если элемент с таким id уже существует, заменяем его
      _currentSimpleUsersList[index] = entity;
    } else {
      // Если элемет с таким id не найден, добавляем новый
      _currentSimpleUsersList.add(entity);
    }

    _currentSimpleUsersList.sortUsersForLastName(true);
  }

  @override
  bool checkEntityNameInList(String email) {
    if (_currentSimpleUsersList.any((element) => element.email.toLowerCase() == email.toLowerCase())) {
      return false;
    } else {
      return true;
    }
  }

  Future<List<ImageFromDb>> searchUnusedImages({required List<ImageFromDb> imagesList}) async {

    if (_currentSimpleUsersList.isEmpty) {
      await getListFromDb();
    }

    // Создаем Set с ID всех изображений, привязанных к мероприятиям
    Set<String> linkedImageIds = _currentSimpleUsersList.map((entity) => entity.uid).toSet();

    // Фильтруем список картинок, оставляя только те, которых нет в Set
    return imagesList.where((image) => !linkedImageIds.contains(image.id) && image.location.location == ImageLocationEnum.users).toList();

  }

  @override
  void deleteEntityFromDownloadedList(String id) {
    if (_currentSimpleUsersList.isNotEmpty){
      _currentSimpleUsersList.removeWhere((admin) => admin.uid == id);
    }
  }



  @override
  Future<List<SimpleUser>> getDownloadedList({bool fromDb = false}) async{
    if (_currentSimpleUsersList.isEmpty || fromDb) {
      await getListFromDb();
    }
    return _currentSimpleUsersList;
  }

  @override
  SimpleUser getEntityFromList(String id) {
    SimpleUser returnedUser = SimpleUser.empty();

    if (_currentSimpleUsersList.isNotEmpty) {
      for (SimpleUser user in _currentSimpleUsersList) {
        if (user.uid == id) {
          returnedUser = user;
          break;
        }
      }
    }
    return returnedUser;
  }




  @override
  Future<List<SimpleUser>> getListFromDb() async{
    DatabaseClass database = DatabaseClass();

    const String path = SimpleUsersConstants.usersPath;

    List<SimpleUser> tempUsersList = [];

    // Подгрузка если платформа не Windows
    if (!Platform.isWindows){
      DataSnapshot? snapshot = await database.getInfoFromDb(path);

      if (snapshot != null && snapshot.exists) {
        for(DataSnapshot user in snapshot.children) {
          if (user.exists){
            tempUsersList.add(SimpleUser.fromSnapshot(user));
          }
        }
      }

    } else {

      // Подгрузка если Windows
      dynamic data = await database.getInfoFromDbForWindows(path);

      if (data != null){
        data.forEach((key, value) {

          tempUsersList.add(
              SimpleUser.fromJson(value)
          );
        });
      }

    }

    // Устанавливаем подгруженный список в нашу доступную переменную
    setDownloadedList(tempUsersList);

    // Сортируем список

    _currentSimpleUsersList.sortUsersForLastName(true);

    return _currentSimpleUsersList;
  }

  @override
  List<SimpleUser> searchElementInList(String query) {
    List<SimpleUser> usersToReturn = _currentSimpleUsersList;

    usersToReturn = usersToReturn
        .where((user) =>
        user.email.toLowerCase().contains(query.toLowerCase())
            || user.getFullName().toLowerCase().contains(query.toLowerCase())
    ).toList();

    return usersToReturn;
  }

  @override
  void setDownloadedList(List<SimpleUser> list) {
    _currentSimpleUsersList = [];
    _currentSimpleUsersList = list;
  }

  Future<String> deletePlaceAdminsFromAllUsers(String placeId) async{

    String result = '';

    for(SimpleUser tempUser in _currentSimpleUsersList){
      if (tempUser.checkAdminRoleInUser(placeId)){
        result = await tempUser.deletePlaceRoleFromUser(placeId);
        addToCurrentDownloadedList(tempUser);
      }
    }

    return result;

  }

  Future<List<SimpleUser>>getAdminsFromPlace({required String placeId, bool fromDb = false}) async {

    List<SimpleUser> tempList = [];

    // Если список пустой, подгружаем простых пользователей
    if (_currentSimpleUsersList.isEmpty){
      await getDownloadedList(fromDb: fromDb);
    }

    // Пробегаемся по каждому пользователю
    for(SimpleUser user in _currentSimpleUsersList){
      // Если есть список заведений у пользователя
      if (user.placesList.isNotEmpty){
        // Пробегаемся по списку заведений
        for (PlaceAdmin admin in user.placesList){
          // Если нужное заведение есть, добавляем в список
          if (admin.placeId == placeId){
            tempList.add(user);
            break;
          }
        }
      }
    }
    return tempList;

  }

}

extension SortSimpleUsersListExtension on List<SimpleUser> {

  void sortUsersForLastName(bool order) {
    if (order) {
      sort((a, b) => a.lastName.compareTo(b.lastName));
    } else {
      sort((a, b) => b.lastName.compareTo(a.lastName));
    }
  }

  void sortUsersForRegDate(bool order) {
    if (order) {
      sort((a, b) => a.registrationDate.compareTo(b.registrationDate));
    } else {
      sort((a, b) => b.registrationDate.compareTo(a.registrationDate));
    }
  }

  void sortUsersForEmail(bool order) {
    if (order) {
      sort((a, b) => a.email.compareTo(b.email));
    } else {
      sort((a, b) => b.email.compareTo(a.email));
    }
  }

}