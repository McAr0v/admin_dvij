import 'dart:io';
import 'package:admin_dvij/constants/privacy_constants.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:admin_dvij/privacy_policy/privacy_enum.dart';
import 'package:admin_dvij/privacy_policy/privacy_policy_class.dart';
import 'package:firebase_database/firebase_database.dart';
import '../database/database_class.dart';

class PrivacyPolicyList implements IEntitiesList<PrivacyPolicyClass>{

  static List<PrivacyPolicyClass> _currentPrivacyPoliciesList = [];

  @override
  void addToCurrentDownloadedList(PrivacyPolicyClass entity) {
    // Проверяем, есть ли элемент с таким id
    int index = _currentPrivacyPoliciesList.indexWhere((c) => c.id == entity.id);



    if (index != -1) {
      // Если элемент с таким id уже существует, заменяем его
      _currentPrivacyPoliciesList[index] = entity;
    } else {
      // Если элемет с таким id не найден, добавляем новый
      _currentPrivacyPoliciesList.add(entity);
    }

    //_currentPrivacyPoliciesList.sortPolicyList(true);
    _currentPrivacyPoliciesList.rightSort();
  }

  Future<void> deactivatedLastActivePrivacy({required String currentActiveId}) async {
    for (PrivacyPolicyClass privacy in _currentPrivacyPoliciesList) {
      if (privacy.isActive() && currentActiveId != privacy.id) {
        privacy.status = PrivacyStatus(privacyEnum: PrivacyEnum.draft);
        await privacy.publishToDb(null);
      }
    }
  }

  @override
  bool checkEntityNameInList(String entity) {
    if (_currentPrivacyPoliciesList.any((element) => element.getFolderId().toLowerCase() == entity.toLowerCase())) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void deleteEntityFromDownloadedList(String id) {
    if (_currentPrivacyPoliciesList.isNotEmpty){
      _currentPrivacyPoliciesList.removeWhere((policy) => policy.getFolderId() == id);
    }
  }

  @override
  Future<List<PrivacyPolicyClass>> getDownloadedList({bool fromDb = false})async {
    if (_currentPrivacyPoliciesList.isEmpty || fromDb) {
      await getListFromDb();
    }
    return _currentPrivacyPoliciesList;
  }

  @override
  PrivacyPolicyClass getEntityFromList(String id) {
    PrivacyPolicyClass returnedPolicy = PrivacyPolicyClass.empty();



    if (_currentPrivacyPoliciesList.isNotEmpty) {
      for (PrivacyPolicyClass policy in _currentPrivacyPoliciesList) {
        if (policy.id == id) {
          returnedPolicy = policy;
          break;
        }
      }
    }
    return returnedPolicy;
  }

  @override
  Future<List<PrivacyPolicyClass>> getListFromDb() async {
    DatabaseClass database = DatabaseClass();

    const String path = PrivacyConstants.privacyPolicyPath;

    List<PrivacyPolicyClass> tempList = [];

    // Подгрузка если платформа не Windows
    if (!Platform.isWindows){
      DataSnapshot? snapshot = await database.getInfoFromDb(path);

      if (snapshot != null && snapshot.exists) {
        for(DataSnapshot idFolder in snapshot.children){
          PrivacyPolicyClass tempEntity = PrivacyPolicyClass.fromSnapshot(snapshot: idFolder);
          tempList.add(tempEntity);
        }
      }

    } else {

      // Подгрузка если Windows

      dynamic data = await database.getInfoFromDbForWindows(path);

      if (data != null){
        data.forEach((key, idFolders) {
          tempList.add(PrivacyPolicyClass.fromJson(json: idFolders));
        });
      }
    }

    // Устанавливаем подгруженный список в нашу доступную переменную
    setDownloadedList(tempList);

    // Сортируем список

    _currentPrivacyPoliciesList.sortPolicyList(true);

    return _currentPrivacyPoliciesList;
  }

  @override
  List<PrivacyPolicyClass> searchElementInList(String query) {
    List<PrivacyPolicyClass> toReturn = _currentPrivacyPoliciesList;

    toReturn = toReturn
        .where((privacy) =>
    privacy.startText.toLowerCase().contains(query.toLowerCase())
        || privacy.changes.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return toReturn;
  }

  @override
  void setDownloadedList(List<PrivacyPolicyClass> list) {
    _currentPrivacyPoliciesList = [];
    _currentPrivacyPoliciesList = list;
  }

}

extension SortPoliciesListExtension on List<PrivacyPolicyClass> {

  void rightSort() {
    sort((a, b) {
      // Сначала сортируем по статусу: active выше, draft ниже
      if (a.status.privacyEnum != b.status.privacyEnum) {
        return a.status.privacyEnum == PrivacyEnum.active ? -1 : 1;
      }

      // Если статусы одинаковые, сортируем по дате создания (от новых к старым)
      return b.date.compareTo(a.date);
    });
  }

  void sortPolicyList(bool order) {
    if (order) {
      sort((a, b) => a.date.compareTo(b.date));
    } else {
      sort((a, b) => b.date.compareTo(a.date));
    }
  }

}