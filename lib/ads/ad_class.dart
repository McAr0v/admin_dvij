import 'dart:io';
import 'package:admin_dvij/ads/ad_for_main_app_class.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_index.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_location.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_status.dart';
import 'package:admin_dvij/ads/ads_list_class.dart';
import 'package:admin_dvij/constants/ads_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:admin_dvij/logs/log_class.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/database_constants.dart';
import '../database/database_class.dart';
import '../database/image_uploader.dart';
import '../design/app_colors.dart';
import '../logs/action_class.dart';
import '../logs/entity_enum.dart';
import '../system_methods/link_methods.dart';
import '../system_methods/system_methods_class.dart';

class AdClass implements IEntity{
  String id;
  String headline;
  String desc;
  String url;
  String imageUrl;
  String buttonHeadline;
  DateTime startDate;
  DateTime endDate;
  AdLocation location;
  AdIndex adIndex;
  AdStatus status;
  String clientName;
  String clientPhone;
  String clientWhatsapp;
  DateTime ordersDate;

  AdClass({
    required this.id,
    required this.headline,
    required this.desc,
    required this.url,
    required this.imageUrl,
    required this.buttonHeadline,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.adIndex,
    required this.status,
    required this.clientName,
    required this.clientPhone,
    required this.clientWhatsapp,
    required this.ordersDate
  });

  factory AdClass.fromSnapshot({required DataSnapshot snapshot}) {

    DateTime startDate = DateTime.parse(snapshot.child(DatabaseConstants.startDate).value.toString());
    DateTime endDate = DateTime.parse(snapshot.child(DatabaseConstants.endDate).value.toString());
    DateTime ordersDate = DateTime.parse(snapshot.child(DatabaseConstants.ordersDate).value.toString());

    return AdClass(
        id: snapshot.child(DatabaseConstants.id).value.toString(),
        headline: snapshot.child(DatabaseConstants.headline).value.toString(),
        buttonHeadline: snapshot.child(DatabaseConstants.buttonHeadline).value.toString(),
        desc: snapshot.child(DatabaseConstants.desc).value.toString(),
        url: snapshot.child(DatabaseConstants.url).value.toString(),
        imageUrl: snapshot.child(DatabaseConstants.imageUrl).value.toString(),
        startDate: startDate,
        endDate: endDate,
        location: AdLocation.fromString(text: snapshot.child(DatabaseConstants.location).value.toString(),),
        adIndex: AdIndex.fromString(text: snapshot.child(DatabaseConstants.adIndex).value.toString()),
        status: AdStatus.fromString(text: snapshot.child(DatabaseConstants.adStatus).value.toString()),
        clientName: snapshot.child(DatabaseConstants.clientName).value.toString(),
        clientPhone: snapshot.child(DatabaseConstants.clientPhone).value.toString(),
        clientWhatsapp: snapshot.child(DatabaseConstants.clientWhatsapp).value.toString(),
        ordersDate: ordersDate
    );
  }

  factory AdClass.fromJson({required Map<String, dynamic> json}){

    DateTime startDate = DateTime.parse(json[DatabaseConstants.startDate] ?? '');
    DateTime endDate = DateTime.parse(json[DatabaseConstants.endDate] ?? '');
    DateTime ordersDate = DateTime.parse(json[DatabaseConstants.ordersDate] ?? '');

    return AdClass(
        id: json[DatabaseConstants.id] ?? '',
        headline: json[DatabaseConstants.headline] ?? '',
        buttonHeadline: json[DatabaseConstants.buttonHeadline] ?? '',
        desc: json[DatabaseConstants.desc] ?? '',
        url: json[DatabaseConstants.url] ?? '',
        imageUrl: json[DatabaseConstants.imageUrl] ?? '',
        startDate: startDate,
        endDate: endDate,
        location: AdLocation.fromString(text: json[DatabaseConstants.location]),
        adIndex: AdIndex.fromString(text: json[DatabaseConstants.adIndex]),
        status: AdStatus.fromString(text: json[DatabaseConstants.adStatus] ?? ''),
        clientName: json[DatabaseConstants.clientName] ?? '',
        clientPhone: json[DatabaseConstants.clientPhone] ?? '',
        clientWhatsapp: json[DatabaseConstants.clientWhatsapp] ?? '',
        ordersDate: ordersDate
    );
  }

  factory AdClass.empty(){
    return AdClass(
        id: '',
        headline: '',
        buttonHeadline: '',
        desc: '',
        url: '',
        imageUrl: SystemConstants.defaultAdImagePath,
        startDate: DateTime(2100),
        endDate: DateTime(2100),
        location: AdLocation(location: AdLocationEnum.notChosen),
        adIndex: AdIndex(index: AdIndexEnum.notChosen),
        status: AdStatus(status: AdStatusEnum.draft),
        clientName: '',
        clientPhone: '',
        clientWhatsapp: '',
        ordersDate: DateTime.now()
    );
  }

  @override
  Future<String> deleteFromDb() async{
    DatabaseClass db = DatabaseClass();
    final ImageUploader imageUploader = ImageUploader();

    String path = '${AdsConstants.adsFolder}/$id/';

    String result = '';

    // Удаляем картинку
    await imageUploader.removeImage(
        folder: AdsConstants.adsFolder,
        entityId: id
    );

    if (!Platform.isWindows){
      result =  await db.deleteFromDb(path);
    } else {
      result = await db.deleteFromDbForWindows(path);
    }

    if (result == SystemConstants.successConst) {
      // Если удаление прошло успешно, удаляем из общего списка
      AdsList adsList = AdsList();
      adsList.deleteEntityFromDownloadedList(id);

    }

    // Если удаляем со статусом "Активно", то удаляем и запись из
    // папки рекламы основного приложения
    if (status.status == AdStatusEnum.active){
      AdForMainApp adForMainApp = AdForMainApp.fromAdClass(adminAd: this);
      result = await adForMainApp.deleteFromDb();
    }

    return result;
  }

  @override
  Map<String, dynamic> getMap() {
    return <String, dynamic> {
      DatabaseConstants.id: id,
      DatabaseConstants.headline: headline,
      DatabaseConstants.desc: desc,
      DatabaseConstants.buttonHeadline: buttonHeadline,
      DatabaseConstants.url: url,
      DatabaseConstants.imageUrl: imageUrl,
      DatabaseConstants.startDate: startDate.toString(),
      DatabaseConstants.endDate: endDate.toString(),
      DatabaseConstants.location: location.toString(),
      DatabaseConstants.adIndex: adIndex.toString(),
      DatabaseConstants.adStatus: status.toString(),
      DatabaseConstants.clientName: clientName,
      DatabaseConstants.clientPhone: clientPhone,
      DatabaseConstants.clientWhatsapp: clientWhatsapp,
      DatabaseConstants.ordersDate: ordersDate.toString(),
    };
  }

  @override
  Future<String> publishToDb(File? imageFile) async {

    LinkMethods lk = LinkMethods();
    DatabaseClass db = DatabaseClass();
    final ImageUploader imageUploader = ImageUploader();

    // Переменная если будет загружаться изображение
    String? postedImageUrl;


    // Если Id не задан
    if (id == '') {
      // Генерируем ID
      String? adId = db.generateKey();

      // Если ID по какой то причине не сгенерировался
      // генерируем вручную
      id = adId ?? 'noID_$headline';

      // Публикуем запись в логе, если создание
      await LogCustom.empty().createAndPublishLog(
          entityId: id,
          entityEnum: EntityEnum.ad,
          actionEnum: ActionEnum.create,
          creatorId: ''
      );
    }

    String path = '${AdsConstants.adsFolder}/$id/';

    if (imageFile != null){

      postedImageUrl = await imageUploader.uploadImage(
          entityId: id,
          pickedFile: imageFile,
          folder: AdsConstants.adsFolder
      );

    }

    clientPhone = lk.formatPhoneNumber(clientPhone);
    clientWhatsapp = lk.extractWhatsAppNumber(clientWhatsapp);

    imageUrl = postedImageUrl ?? imageUrl;

    Map <String, dynamic> userData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, userData);

    } else {

      result = await db.publishToDBForWindows(path, userData);

    }

    if (result == SystemConstants.successConst) {
      // Если результат успешный, добавляем в общий сохраненный список

      AdsList adsList = AdsList();
      adsList.addToCurrentDownloadedList(this);

    }

    // Публикуем копию для основного приложения с активной рекламой

    if (status.status == AdStatusEnum.active){
      AdForMainApp adForMainApp = AdForMainApp.fromAdClass(adminAd: this);
      result = await adForMainApp.publishToDb(null);
    } else {
      AdForMainApp adForMainApp = AdForMainApp.fromAdClass(adminAd: this);
      result = await adForMainApp.deleteFromDb();
    }

    return result;
  }

  String getDatePeriod(){
    SystemMethodsClass sm = SystemMethodsClass();
    return '${sm.formatDateTimeToHumanView(startDate)} - ${sm.formatDateTimeToHumanView(endDate)}';
  }

  Widget getInfoWidget({required BuildContext context}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text('${location.toString(translate: true)}, ${adIndex.toString(translate: true)}', style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText)),
        const SizedBox(height: 10,),
        Row(
          children: [
            if (status.status == AdStatusEnum.active) const Icon(FontAwesomeIcons.solidCircle, color: AppColors.success, size: 6,),
            if (status.status == AdStatusEnum.active) const SizedBox(width: 10,),
            Expanded(child: Text(headline, style: Theme.of(context).textTheme.bodyMedium,)),
          ],
        ),
        const SizedBox(height: 10,),
        Text(
            desc,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis
        ),
        const SizedBox(height: 10,),
        Text(getDatePeriod(), style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText)),
      ],
    );
  }

}