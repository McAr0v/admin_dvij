import 'dart:io';
import 'package:admin_dvij/categories/event_categories/event_categories_list.dart';
import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/constants/date_constants.dart';
import 'package:admin_dvij/constants/event_type_constants.dart';
import 'package:admin_dvij/constants/events_constants.dart';
import 'package:admin_dvij/constants/places_constants.dart';
import 'package:admin_dvij/constants/price_type_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/dates/date_type.dart';
import 'package:admin_dvij/events/events_list_class.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:admin_dvij/places/places_list_class.dart';
import 'package:admin_dvij/price_type/price_type_class.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/simple_users/simple_user.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../categories/event_categories/event_category.dart';
import '../cities/city_class.dart';
import '../constants/database_constants.dart';
import '../database/database_class.dart';
import '../database/image_uploader.dart';
import '../dates/irregular_date.dart';
import '../dates/long_date.dart';
import '../dates/once_date.dart';
import '../dates/regular_date_class.dart';
import '../design/app_colors.dart';
import '../design_elements/elements_of_design.dart';
import '../logs/action_class.dart';
import '../logs/entity_enum.dart';
import '../logs/log_class.dart';
import '../places/place_class.dart';
import '../system_methods/link_methods.dart';
import '../system_methods/methods_for_database.dart';

class EventClass implements IEntity{

  String id;
  DateType dateType;
  String headline;
  String desc;
  String creatorId;
  DateTime createDate;
  EventCategory category;
  City city;
  String street;
  String house;
  String phone;
  String whatsapp;
  String telegram;
  String instagram;
  String imageUrl;
  String placeId;
  PriceType priceType;
  String price;
  OnceDate onceDay;
  LongDate longDays;
  RegularDate regularDays;
  IrregularDate irregularDays;
  List<String> favUsersIds;
  bool createdByAdmin;

  EventClass({
    required this.id,
    required this.dateType,
    required this.headline,
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
    required this.placeId,
    required this.priceType,
    required this.price,
    required this.onceDay,
    required this.longDays,
    required this.regularDays,
    required this.irregularDays,
    this.favUsersIds = const [],
    required this.createdByAdmin
  });

  factory EventClass.empty(){
    return EventClass(
        id: '',
        dateType: DateType(),
        headline: '',
        desc: '',
        creatorId: '',
        createDate: DateTime.now(),
        category: EventCategory.empty(),
        city: City.empty(),
        street: '',
        house: '',
        phone: '',
        whatsapp: '',
        telegram: '',
        instagram: '',
        imageUrl: SystemConstants.noImagePath,
        placeId: '',
        priceType: PriceType(),
        price: '',
        onceDay: OnceDate.empty(),
        longDays: LongDate.empty(),
        regularDays: RegularDate(),
        irregularDays: IrregularDate.empty(),
        createdByAdmin: true
    );
  }

  factory EventClass.fromSnapshot({required DataSnapshot snapshot}){

    DataSnapshot infoFolder = snapshot.child(EventsConstants.eventsInfoFolder);
    DataSnapshot favFolder = snapshot.child(DatabaseConstants.addedToFavourites);

    MethodsForDatabase methodsForDatabase = MethodsForDatabase();
    EventCategoriesList eventCategoriesList = EventCategoriesList();
    CitiesList citiesList = CitiesList();

    IrregularDate irregularDate = IrregularDate.fromJson(json: infoFolder.child(DateConstants.irregularDaysId).value.toString());

    irregularDate.sortDates();

    return EventClass(
        id: infoFolder.child(DatabaseConstants.id).value.toString(),
        dateType: DateType.fromString(enumString: infoFolder.child(EventTypeConstants.eventTypeId).value.toString()),
        headline: infoFolder.child(DatabaseConstants.headline).value.toString(),
        desc: infoFolder.child(DatabaseConstants.desc).value.toString(),
        creatorId: infoFolder.child(DatabaseConstants.creatorId).value.toString(),
        createDate: DateTime.parse(infoFolder.child(DatabaseConstants.createDate).value.toString()),
        category: eventCategoriesList.getEntityFromList(infoFolder.child(DatabaseConstants.category).value.toString()),
        city: citiesList.getEntityFromList(infoFolder.child(DatabaseConstants.city).value.toString()),
        street: infoFolder.child(DatabaseConstants.street).value.toString(),
        house: infoFolder.child(DatabaseConstants.house).value.toString(),
        phone: infoFolder.child(DatabaseConstants.phone).value.toString(),
        whatsapp: infoFolder.child(DatabaseConstants.whatsapp).value.toString(),
        telegram: infoFolder.child(DatabaseConstants.telegram).value.toString(),
        instagram: infoFolder.child(DatabaseConstants.instagram).value.toString(),
        imageUrl: infoFolder.child(DatabaseConstants.imageUrl).value.toString(),
        placeId: infoFolder.child(DatabaseConstants.placeId).value.toString(),
        priceType: PriceType.fromString(enumString: infoFolder.child(PriceTypeConstants.priceTypeId).value.toString()),
        price: infoFolder.child(DatabaseConstants.price).value.toString(),
        onceDay: OnceDate.fromJson(jsonString: infoFolder.child(DateConstants.onceDayId).value.toString()),
        longDays: LongDate.fromJson(jsonString: infoFolder.child(DateConstants.longDaysId).value.toString()),
        regularDays: RegularDate.fromJson(infoFolder.child(DateConstants.regularDaysId).value.toString()),
        irregularDays: irregularDate,
        favUsersIds: methodsForDatabase.getStringFromKeyFromSnapshot(snapshot: favFolder, key: DatabaseConstants.userId),
        createdByAdmin: SystemMethodsClass().getCreatedByAdmin(data: infoFolder.child(DatabaseConstants.createdByAdmin).value.toString())
    );
  }

  factory EventClass.fromJson({required Map<String, dynamic> json}){

    Map<String, dynamic> infoFolder = json[EventsConstants.eventsInfoFolder];
    Map<String, dynamic>? favFolder = json[DatabaseConstants.addedToFavourites];

    MethodsForDatabase methodsForDatabase = MethodsForDatabase();
    EventCategoriesList eventCategoriesList = EventCategoriesList();
    CitiesList citiesList = CitiesList();

    IrregularDate irregularDate = IrregularDate.fromJson(json: infoFolder[DateConstants.irregularDaysId] ?? '');

    irregularDate.sortDates();

    return EventClass(
        id: infoFolder[DatabaseConstants.id] ?? '',
        dateType: DateType.fromString(enumString: infoFolder[EventTypeConstants.eventTypeId] ?? ''),
        headline: infoFolder[DatabaseConstants.headline] ?? '',
        desc: infoFolder[DatabaseConstants.desc] ?? '',
        creatorId: infoFolder[DatabaseConstants.creatorId] ?? '',
        createDate: DateTime.parse(infoFolder[DatabaseConstants.createDate] ?? ''),
        category: eventCategoriesList.getEntityFromList(infoFolder[DatabaseConstants.category] ?? ''),
        city: citiesList.getEntityFromList(infoFolder[DatabaseConstants.city] ?? ''),
        street: infoFolder[DatabaseConstants.street] ?? '',
        house: infoFolder[DatabaseConstants.house] ?? '',
        phone: infoFolder[DatabaseConstants.phone] ?? '',
        whatsapp: infoFolder[DatabaseConstants.whatsapp] ?? '',
        telegram: infoFolder[DatabaseConstants.telegram] ?? '',
        instagram: infoFolder[DatabaseConstants.instagram] ?? '',
        imageUrl: infoFolder[DatabaseConstants.imageUrl] ?? '',
        placeId: infoFolder[DatabaseConstants.placeId] ?? '',
        priceType: PriceType.fromString(enumString: infoFolder[PriceTypeConstants.priceTypeId] ?? ''),
        price: infoFolder[DatabaseConstants.price] ?? '',
        onceDay: OnceDate.fromJson(jsonString: infoFolder[DateConstants.onceDayId] ?? ''),
        longDays: LongDate.fromJson(jsonString: infoFolder[DateConstants.longDaysId] ?? ''),
        regularDays: RegularDate.fromJson(infoFolder[DateConstants.regularDaysId] ?? ''),
        irregularDays: irregularDate,
        favUsersIds: favFolder != null ? methodsForDatabase.getStringFromKeyFromJson(json: favFolder, inputKey: DatabaseConstants.userId) : [],
        createdByAdmin: SystemMethodsClass().getCreatedByAdmin(data: infoFolder[DatabaseConstants.createdByAdmin])
    );
  }

  @override
  Future<String> deleteFromDb() async {

    SimpleUsersList simpleUsersList = SimpleUsersList();

    SimpleUser creator = simpleUsersList.getEntityFromList(creatorId);

    PlacesList placesList = PlacesList();
    final ImageUploader imageUploader = ImageUploader();

    DatabaseClass db = DatabaseClass();

    String path = '${EventsConstants.eventsPath}/$id/';

    String result = '';

    await imageUploader.removeImage(
        folder: EventsConstants.eventsPath,
        entityId: id
    );

    if (!Platform.isWindows){
      result =  await db.deleteFromDb(path);
    } else {
      result = await db.deleteFromDbForWindows(path);
    }

    // Если мероприятие от заведения
    if (placeId.isNotEmpty){
      // Удаляем в заведении нашe мероприятие
      Place place = placesList.getEntityFromList(placeId);
      await place.deleteEventFromPlace(eventId: id);
      placesList.addToCurrentDownloadedList(place);
    }

    if (creator.uid.isNotEmpty){
      await creator.deleteEventFromMyEvents(eventId: id);
      simpleUsersList.addToCurrentDownloadedList(creator);
    }

    if (result == SystemConstants.successConst) {
      // Если удаление прошло успешно, удаляем из общего списка
      EventsListClass eventsList = EventsListClass();
      eventsList.deleteEntityFromDownloadedList(id);
    }

    return result;
  }



  @override
  Map<String, dynamic> getMap() {
    return <String, dynamic> {
      DatabaseConstants.id: id,
      DatabaseConstants.headline: headline,
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
      EventTypeConstants.eventTypeId: dateType.toString(),
      DatabaseConstants.placeId: placeId,
      PriceTypeConstants.priceTypeId: priceType.toString(),
      DatabaseConstants.price: price,
      DateConstants.onceDayId: onceDay.toJsonString(),
      DateConstants.longDaysId: longDays.toJsonString(),
      DateConstants.regularDaysId: regularDays.toJsonString(),
      DateConstants.irregularDaysId: irregularDays.toJson(),
      DatabaseConstants.createdByAdmin: createdByAdmin.toString()
    };
  }

  @override
  Future<String> publishToDb(File? imageFile) async{
    SimpleUsersList simpleUsersList = SimpleUsersList();
    SimpleUser creator = simpleUsersList.getEntityFromList(creatorId);
    PlacesList placesList = PlacesList();
    LinkMethods lk = LinkMethods();

    DatabaseClass db = DatabaseClass();
    final ImageUploader imageUploader = ImageUploader();

    // Переменная если будет загружаться изображение
    String? postedImageUrl;

    // Если Id не задан
    if (id == '') {
      // Генерируем ID
      String? idEvent = db.generateKey();

      // Если ID по какой то причине не сгенерировался
      // генерируем вручную
      id = idEvent ?? 'noId_$headline';

      // Публикуем запись в логе, если создание
      await LogCustom.empty().createAndPublishLog(
          entityId: id,
          entityEnum: EntityEnum.event,
          actionEnum: ActionEnum.create,
          creatorId: creatorId
      );

    }

    if (imageFile != null){

      postedImageUrl = await imageUploader.uploadImage(
          entityId: id,
          pickedFile: imageFile,
          folder: EventsConstants.eventsPath
      );

    }

    imageUrl = postedImageUrl ?? imageUrl;

    phone = lk.formatPhoneNumber(phone);
    instagram = lk.extractInstagramUsername(instagram);
    telegram = lk.extractTelegramUsername(telegram);
    whatsapp = lk.extractWhatsAppNumber(whatsapp);

    String path = '${EventsConstants.eventsPath}/$id/${EventsConstants.eventsInfoFolder}';

    Map <String, dynamic> eventData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, eventData);

    } else {

      result = await db.publishToDBForWindows(path, eventData);

    }

    // Если мероприятие от заведения
    if (placeId.isNotEmpty){
      // Добавляем в заведении нашe мероприятие
      Place place = placesList.getEntityFromList(placeId);
      if (place.id.isNotEmpty){
        await place.addEventToPlace(eventId: id);
        placesList.addToCurrentDownloadedList(place);
      }

    }

    if (creator.uid.isNotEmpty){
      await creator.addEventToMyEvents(eventId: id);
      simpleUsersList.addToCurrentDownloadedList(creator);
    }

    if (result == SystemConstants.successConst) {
      // Если результат успешный, добавляем в общий сохраненный список
      EventsListClass eventsList = EventsListClass();
      eventsList.addToCurrentDownloadedList(this);
    }

    return result;
  }

  Widget getFavCounterWidget({required BuildContext context}){
    return ElementsOfDesign.getTag(
        context: context,
        text: favUsersIds.length.toString(),
        icon: FontAwesomeIcons.heart,
        color: AppColors.greyBackground,
        textColor: AppColors.white

    );
  }

  Widget getPriceWidget({required BuildContext context}){
    return ElementsOfDesign.getTag(
        context: context,
        text: priceType.getHumanViewPrice(price: price),
        icon: FontAwesomeIcons.tengeSign,
        color: AppColors.greyBackground,
        textColor: AppColors.white

    );
  }

  Widget getDateTypeWidget({required BuildContext context}){
    return ElementsOfDesign.getTag(
        context: context,
        text: dateType.toString(translate: true),
        icon: FontAwesomeIcons.calendar,
        color: AppColors.greyBackground,
        textColor: AppColors.white

    );
  }

  Widget getEventsDatesWidget({required BuildContext context}){
    return ElementsOfDesign.getTag(
        context: context,
        text: getDatesToHumanView(),
        icon: FontAwesomeIcons.calendar,
        color: AppColors.greyBackground,
        textColor: AppColors.white
    );
  }

  Widget getEventsTimeWidget({required BuildContext context}){
    return ElementsOfDesign.getTag(
        context: context,
        text: getTimeToHumanView(),
        icon: FontAwesomeIcons.clock,
        color: AppColors.greyBackground,
        textColor: AppColors.white
    );
  }

  bool isFinished(){
    switch (dateType.dateType) {
      case DateTypeEnum.once : return onceDay.isFinished();
      case DateTypeEnum.long : return longDays.isFinished();
      case DateTypeEnum.regular : return false;
      case DateTypeEnum.irregular: return irregularDays.isFinished();
      case DateTypeEnum.notChosen: return true;
    }
  }

  Widget getEventStatusWidget({required BuildContext context}){
    return ElementsOfDesign.getTag(
        context: context,
        text: isFinished() ? SystemConstants.finishedStatus : SystemConstants.activeStatus,
        icon: isFinished() ? FontAwesomeIcons.flagCheckered : FontAwesomeIcons.circleDot,
        color: isFinished() ?  AppColors.greyBackground : AppColors.success,
        textColor: AppColors.white
    );
  }

  Widget? inPlaceWidget({required BuildContext context}){
    if (placeId.isNotEmpty) {
      return ElementsOfDesign.getTag(
          context: context,
          text: PlacesConstants.fromPlace,
          icon: FontAwesomeIcons.locationPin,
          color: AppColors.greyBackground,
          textColor: AppColors.white
      );
    } else {
      return null;
    }

  }

  String getDatesToHumanView(){
    if (dateType.dateType == DateTypeEnum.once){
      return onceDay.getHumanViewDate();
    } else if (dateType.dateType == DateTypeEnum.long){
      return longDays.getHumanViewDate();
    } else if (dateType.dateType == DateTypeEnum.regular) {
      return regularDays.getHumanViewDate();
    } else {
      return DateConstants.inRandomDates;
    }
  }

  String getTimeToHumanView(){
    if (dateType.dateType == DateTypeEnum.once){
      return onceDay.getTimePeriod();
    } else if (dateType.dateType == DateTypeEnum.long){
      return longDays.getTimePeriod();
    } else {
      return DateConstants.fromSchedule;
    }
  }

}