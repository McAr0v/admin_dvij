import 'dart:io';
import 'package:admin_dvij/categories/promo_categories/promo_category.dart';
import 'package:admin_dvij/constants/promo_constants.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:admin_dvij/promos/promo_class.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../cities/city_class.dart';
import '../database/database_class.dart';
import '../design/app_colors.dart';
import '../design_elements/elements_of_design.dart';

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

  Future<List<Promo>> getPromosListFromSimpleUser({required List<String> promosIdList}) async{

    List<Promo> returnedList = [];

    if (_currentPromosList.isEmpty){
      await getListFromDb();
    }

    for (String eventId in promosIdList){
      Promo tempPromo = getEntityFromList(eventId);
      if (tempPromo.id == eventId){
        returnedList.add(tempPromo);
      }
    }

    return returnedList;

  }

  Widget getPromosListWidget({
    required List<Promo> promosList,
    required VoidCallback onTap,
    required BuildContext context,
    required bool showPromos,
    required void Function(int index) editPromo

  }){
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: AppColors.greyBackground,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Акции (${promosList.length})', style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                  ),
                  IconButton(
                      onPressed: onTap,
                      icon: Icon(showPromos ? FontAwesomeIcons.chevronDown : FontAwesomeIcons.chevronRight, size: 15,)
                  )
                ],
              ),

              if (promosList.isNotEmpty && showPromos) for (int i = 0; i < promosList.length; i++) Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: GestureDetector(
                  onTap: () => editPromo(i),
                  child: Card(
                    color: AppColors.greyOnBackground,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElementsOfDesign.imageWithTags(
                            imageUrl: promosList[i].imageUrl,
                            width: 100, //Platform.isWindows || Platform.isMacOS ? 100 : double.infinity,
                            height: 100,
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(promosList[i].headline),
                                  const SizedBox(height: 5,),
                                  Text(
                                    promosList[i].desc,
                                    style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 10,),
                                  Wrap(
                                    children: [
                                      promosList[i].getEventStatusWidget(context: context),
                                      promosList[i].category.getCategoryWidget(context: context)
                                    ],
                                  )
                                ],
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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