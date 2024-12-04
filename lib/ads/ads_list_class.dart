import 'dart:io';

import 'package:admin_dvij/ads/ad_class.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_status.dart';
import 'package:admin_dvij/constants/ads_constants.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:firebase_database/firebase_database.dart';

import '../database/database_class.dart';

class AdsList implements IEntitiesList<AdClass>{
  AdsList();

  static List<AdClass> _currentAdsList = [];

  @override
  void addToCurrentDownloadedList(AdClass entity) {
    // Проверяем, есть ли элемент с таким id
    int index = _currentAdsList.indexWhere((c) => c.id == entity.id);

    if (index != -1) {
      // Если элемент с таким id уже существует, заменяем его
      _currentAdsList[index] = entity;
    } else {
      // Если элемет с таким id не найден, добавляем новый
      _currentAdsList.add(entity);
    }

    _currentAdsList.sortAds(true);
  }

  @override
  bool checkEntityNameInList(String entity) {
    final now = DateTime.now(); // Текущее время

    if (_currentAdsList.isNotEmpty){
      AdClass tempAd = getEntityFromList(entity);

      return now.isAfter(tempAd.startDate) || now.isAtSameMomentAs(tempAd.startDate) &&
          now.isBefore(tempAd.endDate) || now.isAtSameMomentAs(tempAd.endDate);

    } else {
      return false;
    }

  }

  @override
  void deleteEntityFromDownloadedList(String id) {
    if (_currentAdsList.isNotEmpty){
      _currentAdsList.removeWhere((admin) => admin.id == id);
    }
  }

  @override
  Future<List<AdClass>> getDownloadedList({bool fromDb = false}) async{
    if (_currentAdsList.isEmpty || fromDb) {
      await getListFromDb();
    }
    return _currentAdsList;
  }

  @override
  AdClass getEntityFromList(String id) {
    AdClass returnedAd = AdClass.empty();

    if (_currentAdsList.isNotEmpty) {
      for (AdClass ad in _currentAdsList) {
        if (ad.id == id) {
          returnedAd = ad;
          break;
        }
      }
    }
    return returnedAd;
  }

  @override
  Future<List<AdClass>> getListFromDb() async{
    DatabaseClass database = DatabaseClass();

    const String path = AdsConstants.adsFolder;

    List<AdClass> tempAds = [];

    // Подгрузка если платформа не Windows
    if (!Platform.isWindows){
      DataSnapshot? snapshot = await database.getInfoFromDb(path);

      if (snapshot != null && snapshot.exists) {
        for(DataSnapshot location in snapshot.children) {
          for(DataSnapshot index in location.children){
            for(DataSnapshot idFolder in index.children){
              AdClass tempAd = AdClass.fromSnapshot(snapshot: idFolder);
              tempAds.add(tempAd);
            }
          }
        }
      }

    } else {

      // Подгрузка если Windows
      dynamic data = await database.getInfoFromDbForWindows(path);

      if (data != null){
        data.forEach((key, location) {
          location.forEach((key, index){
            index.forEach((key, idsFolders){
              tempAds.add(
                  AdClass.fromJson(json: idsFolders)
              );
            });
          });
        });
      }
    }

    // Устанавливаем подгруженный список в нашу доступную переменную
    setDownloadedList(tempAds);

    // Сортируем список

    _currentAdsList.sortAds(true);

    return _currentAdsList;
  }

  @override
  List<AdClass> searchElementInList(String query) {
    List<AdClass> adsToReturn = _currentAdsList;

    adsToReturn = adsToReturn
        .where((ad) =>
    ad.headline.toLowerCase().contains(query.toLowerCase())
        || ad.desc.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return adsToReturn;
  }

  @override
  void setDownloadedList(List<AdClass> list) {
    _currentAdsList = [];
    _currentAdsList = list;
  }

  Future<List<AdClass>> getActiveAds({bool fromDb = false}) async {
    List<AdClass> tempList = [];

    if (_currentAdsList.isEmpty || fromDb){
      await getListFromDb();
    }

    for (AdClass ad in _currentAdsList){
      if (ad.status.status == AdStatusEnum.active){
        tempList.add(ad);
      }
    }

    return tempList;
  }

  Future<List<AdClass>> getDraftAds({bool fromDb = false}) async {
    List<AdClass> tempList = [];

    if (_currentAdsList.isEmpty || fromDb){
      await getListFromDb();
    }

    for (AdClass ad in _currentAdsList){
      if (ad.status.status == AdStatusEnum.draft){
        tempList.add(ad);
      }
    }

    return tempList;
  }

  Future<List<AdClass>> getCompletedAds({bool fromDb = false}) async {
    List<AdClass> tempList = [];

    if (_currentAdsList.isEmpty || fromDb){
      await getListFromDb();
    }

    for (AdClass ad in _currentAdsList){
      if (ad.status.status == AdStatusEnum.completed){
        tempList.add(ad);
      }
    }

    return tempList;
  }


}

extension SortAdminUsersListExtension on List<AdClass> {

  void sortAds(bool order) {
    if (order) {
      sort((a, b) => a.location.toString().compareTo(b.location.toString()));
    } else {
      sort((a, b) => b.location.toString().compareTo(a.location.toString()));
    }
  }

}