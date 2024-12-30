import 'dart:io';
import 'package:admin_dvij/categories/promo_categories/promo_category.dart';
import 'package:admin_dvij/constants/promo_constants.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:admin_dvij/promos/promo_class.dart';
import 'package:firebase_database/firebase_database.dart';
import '../cities/city_class.dart';
import '../database/database_class.dart';

class PromosListClass implements IEntitiesList<Promo> {

  static List<Promo> _currentPromosList = [];

  @override
  void addToCurrentDownloadedList(Promo entity) {
    // Проверяем, есть ли элемент с таким id
    int index = _currentPromosList.indexWhere((c) => c.id == entity.id);

    if (index != -1) {
      // Если элемент с таким id уже существует, заменяем его
      _currentPromosList[index] = entity;
    } else {
      // Если элемет с таким id не найден, добавляем новый
      _currentPromosList.add(entity);
    }

    _currentPromosList.sortPromos(true);
  }

  @override
  bool checkEntityNameInList(String entity) {
    if (_currentPromosList.any((element) => element.id.toLowerCase() == entity.toLowerCase())) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void deleteEntityFromDownloadedList(String id) {
    if (_currentPromosList.isNotEmpty){
      _currentPromosList.removeWhere((promo) => promo.id == id);
    }
  }

  @override
  Future<List<Promo>> getDownloadedList({bool fromDb = false}) async {
    if (_currentPromosList.isEmpty || fromDb) {
      await getListFromDb();
    }
    return _currentPromosList;
  }

  @override
  Promo getEntityFromList(String id) {
    Promo returnedPromo = Promo.empty();

    if (_currentPromosList.isNotEmpty) {
      for (Promo promo in _currentPromosList) {
        if (promo.id == id) {
          returnedPromo = promo;
          break;
        }
      }
    }
    return returnedPromo;
  }

  @override
  Future<List<Promo>> getListFromDb() async {
    DatabaseClass database = DatabaseClass();

    const String path = PromoConstants.promosPath;

    List<Promo> tempList = [];

    // Подгрузка если платформа не Windows
    if (!Platform.isWindows){
      DataSnapshot? snapshot = await database.getInfoFromDb(path);

      if (snapshot != null && snapshot.exists) {
        for(DataSnapshot idFolder in snapshot.children){
          Promo tempEntity = Promo.fromSnapshot(snapshot: idFolder);
          tempList.add(tempEntity);
        }
      }

    } else {

      // Подгрузка если Windows

      dynamic data = await database.getInfoFromDbForWindows(path);

      if (data != null){
        data.forEach((key, idFolders) {
          tempList.add(Promo.fromJson(json: idFolders));
        });
      }
    }

    // Устанавливаем подгруженный список в нашу доступную переменную
    setDownloadedList(tempList);

    // Сортируем список

    _currentPromosList.sortPromos(true);

    return _currentPromosList;
  }

  @override
  List<Promo> searchElementInList(String query) {
    List<Promo> promosToReturn = _currentPromosList;

    promosToReturn = promosToReturn
        .where((place) =>
    place.headline.toLowerCase().contains(query.toLowerCase())
        || place.desc.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return promosToReturn;
  }

  @override
  void setDownloadedList(List<Promo> list) {
    _currentPromosList = [];
    _currentPromosList = list;
  }

  Future<List<Promo>> getNeededPromos({
    bool fromDb = false,
    required City filterCity,
    required PromoCategory filterCategory,
    required bool filterInPlace,
    required String searchingText,
    required bool isActive
  }) async {

    List<Promo> returnedList = [];

    if (_currentPromosList.isEmpty || fromDb){
      await getListFromDb();
    }

    for (Promo tempPromo in _currentPromosList){

      // Если нужен список активных
      if(isActive){

        // Если активное
        if (!tempPromo.isFinished()){

          // Проверяем на совпадение значениям фильтра
          if (checkPromoOnFilter(
              filterCity: filterCity,
              filterCategory: filterCategory,
              filterInPlace: filterInPlace,
              tempPromo: tempPromo)
          ){
            returnedList.add(tempPromo);
          }
        }
      }
      // Если нужен список завершенных
      else {

        // Если завершено
        if (tempPromo.isFinished()){

          // Проверяем на совпадение значениям фильтра
          if (checkPromoOnFilter(
              filterCity: filterCity,
              filterCategory: filterCategory,
              filterInPlace: filterInPlace,
              tempPromo: tempPromo)
          ){
            returnedList.add(tempPromo);
          }
        }
      }
    }

    if (searchingText.isNotEmpty){
      returnedList = returnedList
          .where((event) =>
      event.headline.toLowerCase().contains(searchingText.toLowerCase()) ||
          event.desc.toLowerCase().contains(searchingText.toLowerCase()) ||
          event.city.name.toLowerCase().contains(searchingText.toLowerCase()) ||
          event.category.name.toLowerCase().contains(searchingText.toLowerCase()) ||
          event.street.toLowerCase().contains(searchingText.toLowerCase())
      ).toList();
    }

    return returnedList;

  }

  bool checkPromoOnFilter({
    required City filterCity,
    required PromoCategory filterCategory,
    required bool filterInPlace,
    required Promo tempPromo,
  }) {
    // Проверка города
    final bool cityMatches = filterCity.id.isEmpty || tempPromo.city.id == filterCity.id;

    // Проверка категории
    final bool categoryMatches = filterCategory.id.isEmpty || tempPromo.category.id == filterCategory.id;

    // Проверка на то, находится ли событие в заведении
    final bool inPlaceMatches = !filterInPlace || tempPromo.placeId.isNotEmpty;

    // Если все фильтры соответствуют, возвращаем true
    return cityMatches && categoryMatches && inPlaceMatches;
  }

}

extension SortPromosListExtension on List<Promo> {

  void sortPromos(bool order) {
    if (order) {
      sort((a, b) => a.createDate.compareTo(b.createDate));
    } else {
      sort((a, b) => b.createDate.compareTo(a.createDate));
    }
  }

}