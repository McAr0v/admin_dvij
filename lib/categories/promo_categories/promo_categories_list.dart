import 'dart:io';
import 'package:admin_dvij/categories/promo_categories/promo_category.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../constants/categories_constants.dart';
import '../../database/database_class.dart';

class PromoCategoriesList implements IEntitiesList<PromoCategory>{
  PromoCategoriesList();

  static List<PromoCategory> _currentPromoCategoriesList = [];

  @override
  void addToCurrentDownloadedList(PromoCategory entity) {
    // Проверяем, есть ли элемент с таким id
    int index = _currentPromoCategoriesList.indexWhere((c) => c.id == entity.id);

    if (index != -1) {
      // Если элемент с таким id уже существует, заменяем его
      _currentPromoCategoriesList[index] = entity;
    } else {
      // Если элемет с таким id не найден, добавляем новый
      _currentPromoCategoriesList.add(entity);
    }

    // Сортируем список
    _currentPromoCategoriesList.sortPromoCategories(true);
  }

  @override
  bool checkEntityNameInList(String entity) {
    if (_currentPromoCategoriesList.any((element) => element.name.toLowerCase() == entity.toLowerCase())) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void deleteEntityFromDownloadedList(String id) {
    if (_currentPromoCategoriesList.isNotEmpty){
      _currentPromoCategoriesList.removeWhere((category) => category.id == id);
    }
  }

  @override
  Future<List<PromoCategory>> getDownloadedList({bool fromDb = false}) async {
    if (_currentPromoCategoriesList.isEmpty || fromDb) {
      await getListFromDb();
    }
    return _currentPromoCategoriesList;
  }

  @override
  PromoCategory getEntityFromList(String id) {
    PromoCategory returnedCategory = PromoCategory.empty();

    if (_currentPromoCategoriesList.isNotEmpty){
      for (PromoCategory category in _currentPromoCategoriesList) {
        if (category.id == id) {
          returnedCategory = category;
          break;
        }
      }
    }
    return returnedCategory;
  }

  @override
  Future<List<PromoCategory>> getListFromDb() async{
    DatabaseClass database = DatabaseClass();

    String path = CategoriesConstants.promoCategoryPath;

    List<PromoCategory> tempCategories = [];

    // Подгрузка если платформа не Windows
    if (!Platform.isWindows){
      DataSnapshot? snapshot = await database.getInfoFromDb(path);

      if (snapshot != null && snapshot.exists) {
        for(DataSnapshot category in snapshot.children) {
          PromoCategory tempCategory = PromoCategory.fromSnapshot(snapshot: category);
          tempCategories.add(tempCategory);
        }
      }

    } else {

      // Подгрузка если Windows
      dynamic data = await database.getInfoFromDbForWindows(path);

      if (data != null){
        data.forEach((key, value) {

          tempCategories.add(
              PromoCategory.fromJson(json: value)
          );
        });
      }

    }

    // Устанавливаем подгруженный список в нашу доступную переменную
    setDownloadedList(tempCategories);

    // Сортируем список
    _currentPromoCategoriesList.sortPromoCategories(true);

    return _currentPromoCategoriesList;
  }

  @override
  List<PromoCategory> searchElementInList(String query) {
    List<PromoCategory> categoriesToReturn = _currentPromoCategoriesList;

    categoriesToReturn = categoriesToReturn
        .where((client) =>
        client.name.toLowerCase().contains(query.toLowerCase())).toList();

    return categoriesToReturn;
  }

  @override
  void setDownloadedList(List<PromoCategory> list) {
    _currentPromoCategoriesList = [];
    _currentPromoCategoriesList = list;
  }

}

extension SortPromoCategoryListExtension on List<PromoCategory> {

  void sortPromoCategories(bool order) {
    if (order) {
      sort((a, b) => a.name.compareTo(b.name));
    } else {
      sort((a, b) => b.name.compareTo(a.name));
    }
  }
}