import 'dart:io';
import 'package:admin_dvij/categories/place_categories/place_categories_list.dart';
import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/constants/database_constants.dart';
import 'package:admin_dvij/constants/places_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/design/app_colors.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:admin_dvij/places/place_admin/place_admin_class.dart';
import 'package:admin_dvij/places/place_admin/place_role_class.dart';
import 'package:admin_dvij/places/places_list_class.dart';
import 'package:admin_dvij/system_methods/methods_for_database.dart';
import 'package:admin_dvij/users/simple_users/simple_user.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../categories/place_categories/place_category.dart';
import '../cities/city_class.dart';
import '../database/database_class.dart';
import '../database/image_uploader.dart';
import '../dates/regular_date_class.dart';

class Place implements IEntity{
  String id;
  String name;
  String desc;
  String creatorId;
  DateTime createDate;
  PlaceCategory category;
  City city;
  String street;
  String house;
  String phone;
  String whatsapp;
  String telegram;
  String instagram;
  String imageUrl;
  RegularDate openingHours;
  List<String> favUsersIds;
  List<String> eventsList;
  List<String> promosList;

  Place({
    required this.id,
    required this.name,
    required this.desc,
    required this.creatorId,
    required this.createDate,
    required this.category,
    required this.city,
    required this.street,
    required this.house,
    required this.phone,
    required this.whatsapp,
    required this.telegram,
    required this.instagram,
    required this.imageUrl,
    required this.openingHours,
    this.favUsersIds = const [],
    this.eventsList = const [],
    this.promosList = const [],
  });

  factory Place.empty(){
    return Place(
        id: '',
        name: '',
        desc: '',
        creatorId: '',
        createDate: DateTime.now(),
        category: PlaceCategory.empty(),
        city: City.empty(),
        street: '',
        house: '',
        phone: '',
        whatsapp: '',
        telegram: '',
        instagram: '',
        imageUrl: SystemConstants.noImagePath,
        openingHours: RegularDate()
    );
  }

  factory Place.fromSnapshot({required DataSnapshot snapshot}){

    DataSnapshot placeInfoFolder = snapshot.child(PlacesConstants.placeInfoFolder);
    DataSnapshot favFolder = snapshot.child(DatabaseConstants.addedToFavourites);
    DataSnapshot eventsFolder = snapshot.child(DatabaseConstants.events);
    DataSnapshot promosFolder = snapshot.child(DatabaseConstants.promos);

    PlaceCategoriesList placeCategoriesList = PlaceCategoriesList();
    CitiesList citiesList = CitiesList();

    MethodsForDatabase methodsForDatabase = MethodsForDatabase();

    return Place(
        id: placeInfoFolder.child(DatabaseConstants.id).value.toString(),
        name: placeInfoFolder.child(DatabaseConstants.name).value.toString(),
        desc: placeInfoFolder.child(DatabaseConstants.desc).value.toString(),
        creatorId: placeInfoFolder.child(DatabaseConstants.creatorId).value.toString(),
        createDate: DateTime.parse(placeInfoFolder.child(DatabaseConstants.createDate).value.toString()),
        category: placeCategoriesList.getEntityFromList(placeInfoFolder.child(DatabaseConstants.category).value.toString()),
        city: citiesList.getEntityFromList(placeInfoFolder.child(DatabaseConstants.city).value.toString()),
        street: placeInfoFolder.child(DatabaseConstants.street).value.toString(),
        house: placeInfoFolder.child(DatabaseConstants.house).value.toString(),
        phone: placeInfoFolder.child(DatabaseConstants.phone).value.toString(),
        whatsapp: placeInfoFolder.child(DatabaseConstants.whatsapp).value.toString(),
        telegram: placeInfoFolder.child(DatabaseConstants.telegram).value.toString(),
        instagram: placeInfoFolder.child(DatabaseConstants.instagram).value.toString(),
        imageUrl: placeInfoFolder.child(DatabaseConstants.imageUrl).value.toString(),
        openingHours: RegularDate.fromJson(placeInfoFolder.child(DatabaseConstants.openingHours).value.toString()),
        favUsersIds: methodsForDatabase.getStringFromKeyFromSnapshot(snapshot: favFolder, key: DatabaseConstants.userId),
        eventsList: methodsForDatabase.getStringFromKeyFromSnapshot(snapshot: eventsFolder, key: DatabaseConstants.eventId),
        promosList: methodsForDatabase.getStringFromKeyFromSnapshot(snapshot: promosFolder, key: DatabaseConstants.promoId),
    );
  }

  factory Place.fromJson({required Map<String, dynamic> json}){

    Map<String, dynamic> placeInfoFolder = json[PlacesConstants.placeInfoFolder];
    Map<String, dynamic>? favFolder = json[DatabaseConstants.addedToFavourites];
    Map<String, dynamic>? eventsFolder = json[DatabaseConstants.events];
    Map<String, dynamic>? promosFolder = json[DatabaseConstants.promos];

    PlaceCategoriesList placeCategoriesList = PlaceCategoriesList();
    CitiesList citiesList = CitiesList();

    MethodsForDatabase methodsForDatabase = MethodsForDatabase();

    return Place(
      id: placeInfoFolder[DatabaseConstants.id] ?? '',
      name: placeInfoFolder[DatabaseConstants.name] ?? '',
      desc: placeInfoFolder[DatabaseConstants.desc] ?? '',
      creatorId: placeInfoFolder[DatabaseConstants.creatorId] ?? '',
      createDate: DateTime.parse(placeInfoFolder[DatabaseConstants.createDate] ?? ''),
      category: placeCategoriesList.getEntityFromList(placeInfoFolder[DatabaseConstants.category] ?? ''),
      city: citiesList.getEntityFromList(placeInfoFolder[DatabaseConstants.city] ?? ''),
      street: placeInfoFolder[DatabaseConstants.street] ?? '',
      house: placeInfoFolder[DatabaseConstants.house] ?? '',
      phone: placeInfoFolder[DatabaseConstants.phone] ?? '',
      whatsapp: placeInfoFolder[DatabaseConstants.whatsapp] ?? '',
      telegram: placeInfoFolder[DatabaseConstants.telegram] ?? '',
      instagram: placeInfoFolder[DatabaseConstants.instagram] ?? '',
      imageUrl: placeInfoFolder[DatabaseConstants.imageUrl] ?? '',
      openingHours: RegularDate.fromJson(placeInfoFolder[DatabaseConstants.openingHours] ?? ''),
      favUsersIds: favFolder != null ? methodsForDatabase.getStringFromKeyFromJson(json: favFolder, inputKey: DatabaseConstants.userId) : [],
      eventsList: eventsFolder != null ? methodsForDatabase.getStringFromKeyFromJson(json: eventsFolder, inputKey: DatabaseConstants.eventId) : [],
      promosList: promosFolder != null ? methodsForDatabase.getStringFromKeyFromJson(json: promosFolder, inputKey: DatabaseConstants.promoId) : []

    );
  }

  @override
  Future<String> deleteFromDb()async {

    SimpleUsersList usersList = SimpleUsersList();
    final ImageUploader imageUploader = ImageUploader();

    DatabaseClass db = DatabaseClass();

    String path = '${PlacesConstants.placesPath}/$id/';

    String result = '';

    await imageUploader.removeImage(
        folder: PlacesConstants.placesPath,
        entityId: id
    );

    if (!Platform.isWindows){
      result =  await db.deleteFromDb(path);
    } else {
      result = await db.deleteFromDbForWindows(path);
    }

    if (result == SystemConstants.successConst) {
      // Если удаление прошло успешно, удаляем из общего списка
      PlacesList placesList = PlacesList();
      placesList.deleteEntityFromDownloadedList(id);
    }

    await usersList.deletePlaceAdminsFromAllUsers(id);

    if (eventsList.isNotEmpty){
      // TODO Сделать удаление мероприятий этого заведения
    }

    if (promosList.isNotEmpty){
      // TODO Сделать удаление акций этого заведения
    }

    return result;
  }

  @override
  Map<String, dynamic> getMap() {
    return <String, dynamic> {
      DatabaseConstants.id: id,
      DatabaseConstants.name: name,
      DatabaseConstants.desc: desc,
      DatabaseConstants.creatorId: creatorId,
      DatabaseConstants.createDate: createDate.toString(),
      DatabaseConstants.category: category.id,
      DatabaseConstants.city: city.id,
      DatabaseConstants.street: street,
      DatabaseConstants.house: house,
      DatabaseConstants.phone: phone,
      DatabaseConstants.whatsapp: whatsapp,
      DatabaseConstants.telegram: telegram,
      DatabaseConstants.instagram: instagram,
      DatabaseConstants.imageUrl: imageUrl,
      DatabaseConstants.openingHours: openingHours.toJsonString(),
    };
  }

  @override
  Future<String> publishToDb(File? imageFile) async{
    DatabaseClass db = DatabaseClass();
    SimpleUsersList simpleUsersList = SimpleUsersList();
    final ImageUploader imageUploader = ImageUploader();

    // Переменная если будет загружаться изображение
    String? postedImageUrl;

    // Если Id не задан
    if (id == '') {
      // Генерируем ID
      String? idPlace = db.generateKey();

      // Если ID по какой то причине не сгенерировался
      // генерируем вручную
      id = idPlace ?? 'noId_$name';
    }

    if (imageFile != null){

      postedImageUrl = await imageUploader.uploadImage(
          entityId: id,
          pickedFile: imageFile,
          folder: PlacesConstants.placesPath
      );

    }

    imageUrl = postedImageUrl ?? imageUrl;

    String path = '${PlacesConstants.placesPath}/$id/${PlacesConstants.placeInfoFolder}';

    Map <String, dynamic> placeData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, placeData);

    } else {

      result = await db.publishToDBForWindows(path, placeData);

    }

    if (result == SystemConstants.successConst) {
      // Если результат успешный, добавляем в общий сохраненный список
      PlacesList placesList = PlacesList();
      placesList.addToCurrentDownloadedList(this);
    }

    // Получаем создателя
    SimpleUser creator = simpleUsersList.getEntityFromList(creatorId);

    // Публикуем запись о заведении у создателя
    result = await creator.publishPlaceRoleForCurrentUser(
        PlaceAdmin(
            placeId: id,
            placeRole: PlaceRole(
                role: PlaceUserRoleEnum.creator
            )
        )
    );

    return result;
  }

  String getAddress(){
    return '${city.name}, $street $house';
  }

  Future<void> addEventToPlace ({required String eventId}) async {

    DatabaseClass db = DatabaseClass();

    String path = '${PlacesConstants.placesPath}/$id/${DatabaseConstants.events}/$eventId';

    String result = '';

    Map <String, dynamic> data = <String, dynamic> {
      DatabaseConstants.eventId: eventId,
    };

    if (Platform.isWindows){
      result = await db.publishToDBForWindows(path, data);
    } else {
      result = await db.publishToDB(path, data);
    }

    // Проверяем, есть ли у этого заведения мероприятия
    if (eventsList.isNotEmpty){

      // Если есть, проверяем, есть ли уже у списка мероприятий это мероприятие
      int eventIndex = eventsList.indexWhere((c) => c == eventId);

      // Если нет, добавляем
      if (eventIndex == -1){
        eventsList.add(eventId);
      }
    } else {
      // Если список мероприятий заведения пустой, добавляем мероприятие
      eventsList.add(eventId);
    }
  }

  Future<void> deleteEventFromPlace({required String eventId}) async {

    DatabaseClass db = DatabaseClass();

    String path = '${PlacesConstants.placesPath}/$id/${DatabaseConstants.events}/$eventId';

    String result = '';

    if (Platform.isWindows){
      result = await db.deleteFromDbForWindows(path);
    } else {
      result = await db.deleteFromDb(path);
    }

    if (result == SystemConstants.successConst){
      eventsList.removeWhere((c) => c == eventId);
    }
  }

  bool haveEventsOrPromos({bool isEvent = true}){
    if (isEvent){
      if (eventsList.isNotEmpty){
        return true;
      } else {
        return false;
      }
    } else {
      if (promosList.isNotEmpty){
        return true;
      } else {
        return false;
      }
    }
  }

  Widget getFavCounter({required BuildContext context}){
    return ElementsOfDesign.getTag(
        context: context,
        text: favUsersIds.length.toString(),
        icon: FontAwesomeIcons.heart,
        color: AppColors.greyBackground,
        textColor: AppColors.white

    );
  }

  Widget getEventsCounter({required BuildContext context}){
    return ElementsOfDesign.getTag(
        context: context,
        text: eventsList.length.toString(),
        icon: FontAwesomeIcons.cakeCandles,
        color: AppColors.greyBackground,
        textColor: AppColors.white

    );
  }

  Widget getPromosCounter({required BuildContext context}){
    return ElementsOfDesign.getTag(
        context: context,
        text: promosList.length.toString(),
        icon: FontAwesomeIcons.fire,
        color: AppColors.greyBackground,
        textColor: AppColors.white

    );
  }

  PlaceAdmin getCurrentPlaceAdmin({required List<PlaceAdmin> adminsList}){

    for (PlaceAdmin temp in adminsList){
      if (temp.placeId == id){
        return temp;
      }
    }

    return PlaceAdmin(placeRole: PlaceRole());

  }

}