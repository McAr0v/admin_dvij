import 'dart:io';

import 'package:admin_dvij/constants/admins_constants.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/roles/admins_roles_class.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../database/database_class.dart';

class AdminUsersListClass implements IEntitiesList<AdminUserClass>{

  AdminUsersListClass();

  static List<AdminUserClass> _currentAdminsList = [];

  @override
  void addToCurrentDownloadedList(AdminUserClass entity) {

    // Проверяем, есть ли элемент с таким id
    int index = _currentAdminsList.indexWhere((c) => c.uid == entity.uid);

    if (index != -1) {
      // Если элемент с таким id уже существует, заменяем его
      _currentAdminsList[index] = entity;
    } else {
      // Если элемет с таким id не найден, добавляем новый
      _currentAdminsList.add(entity);
    }

    _currentAdminsList.sortAdminsForLastName(true);

  }

  @override
  bool checkEntityNameInList(String email) {
    if (_currentAdminsList.any((element) => element.email.toLowerCase() == email.toLowerCase())) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void deleteEntityFromDownloadedList(String id) {
    if (_currentAdminsList.isNotEmpty){
      _currentAdminsList.removeWhere((admin) => admin.uid == id);
    }
  }

  @override
  Future<List<AdminUserClass>> getDownloadedList({bool fromDb = false}) async{
    if (_currentAdminsList.isEmpty || fromDb) {
      await getListFromDb();
    }
    return _currentAdminsList;
  }

  @override
  Future<List<AdminUserClass>> getListFromDb() async{
    DatabaseClass database = DatabaseClass();

    const String path = AdminConstants.adminsPath;

    List<AdminUserClass> tempAdmins = [];

    // Подгрузка если платформа не Windows
    if (!Platform.isWindows){
      DataSnapshot? snapshot = await database.getInfoFromDb(path);

      if (snapshot != null && snapshot.exists) {
        for(DataSnapshot admin in snapshot.children) {
          AdminUserClass tempAdmin = AdminUserClass.fromSnapshot(admin.child(AdminConstants.adminFolderInfo));
          tempAdmins.add(tempAdmin);
        }
      }

    } else {

      // Подгрузка если Windows
      dynamic data = await database.getInfoFromDbForWindows(path);

      if (data != null){
        data.forEach((key, value) {

          tempAdmins.add(
              AdminUserClass.fromJson(value[AdminConstants.adminFolderInfo])
          );
        });
      }

    }

    // Устанавливаем подгруженный список в нашу доступную переменную
    setDownloadedList(tempAdmins);

    // Сортируем список

    _currentAdminsList.sortAdminsForLastName(true);

    return _currentAdminsList;
  }

  @override
  List<AdminUserClass> searchElementInList(String query) {
    List<AdminUserClass> adminsToReturn = _currentAdminsList;

    adminsToReturn = adminsToReturn
        .where((admin) =>
        admin.email.toLowerCase().contains(query.toLowerCase())
            || admin.getFullName().toLowerCase().contains(query.toLowerCase())
    ).toList();

    return adminsToReturn;
  }

  @override
  void setDownloadedList(List<AdminUserClass> list) {
    _currentAdminsList = [];
    _currentAdminsList = list;
  }

  @override
  AdminUserClass getEntityFromList(String id) {
    AdminUserClass returnedAdmin = AdminUserClass.empty();

    if (_currentAdminsList.isNotEmpty) {
      for (AdminUserClass admin in _currentAdminsList) {
        if (admin.uid == id) {
          returnedAdmin = admin;
          break;
        }
      }
    }
    return returnedAdmin;
  }

  AdminRoleClass getAdminRoleFromList(String id) {

    AdminRoleClass adminRole = AdminRoleClass(AdminRole.notChosen);

    if (_currentAdminsList.isNotEmpty) {
      for (AdminUserClass admin in _currentAdminsList) {
        if (admin.uid == id) {
          adminRole = admin.adminRole;
          break;
        }
      }
    }
    return adminRole;
  }

}

extension SortAdminUsersListExtension on List<AdminUserClass> {

  void sortAdminsForLastName(bool order) {
    if (order) {
      sort((a, b) => a.lastName.compareTo(b.lastName));
    } else {
      sort((a, b) => b.lastName.compareTo(a.lastName));
    }
  }

  void sortAdminsForRegDate(bool order) {
    if (order) {
      sort((a, b) => a.registrationDate.compareTo(b.registrationDate));
    } else {
      sort((a, b) => b.registrationDate.compareTo(a.registrationDate));
    }
  }

  void sortAdminsForEmail(bool order) {
    if (order) {
      sort((a, b) => a.email.compareTo(b.email));
    } else {
      sort((a, b) => b.email.compareTo(a.email));
    }
  }

}