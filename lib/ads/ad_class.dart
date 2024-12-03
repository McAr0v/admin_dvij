import 'dart:io';
import 'package:admin_dvij/ads/ads_enums_class/ad_index.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_location.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_status.dart';
import 'package:admin_dvij/ads/ads_list_class.dart';
import 'package:admin_dvij/constants/ads_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:firebase_database/firebase_database.dart';
import '../constants/database_constants.dart';
import '../database/database_class.dart';
import '../database/image_uploader.dart';

class AdClass implements IEntity{
  String id;
  String headline;
  String desc;
  String url;
  String imageUrl;
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
        desc: snapshot.child(DatabaseConstants.headline).value.toString(),
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
        desc: '',
        url: '',
        imageUrl: SystemConstants.defaultAdImagePath,
        startDate: DateTime(2100),
        endDate: DateTime(2100),
        location: AdLocation(location: AdLocationEnum.notChosen),
        adIndex: AdIndex(index: AdIndexEnum.notChosen),
        status: AdStatus(status: AdStatusEnum.notActive),
        clientName: '',
        clientPhone: '',
        clientWhatsapp: '',
        ordersDate: DateTime(2100)
    );
  }

  @override
  Future<String> deleteFromDb() async{
    DatabaseClass db = DatabaseClass();
    final ImageUploader imageUploader = ImageUploader();

    String path = '${AdsConstants.adsFolder}/${location.toString()}/${adIndex.toString()}/$id/';

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

    return result;
  }

  @override
  Map<String, dynamic> getMap() {
    return <String, dynamic> {
      DatabaseConstants.id: id,
      DatabaseConstants.headline: headline,
      DatabaseConstants.desc: desc,
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
    }

    String path = '${AdsConstants.adsFolder}/${location.toString()}/${adIndex.toString()}/$id/';

    if (imageFile != null){

      postedImageUrl = await imageUploader.uploadImage(
          entityId: id,
          pickedFile: imageFile,
          folder: AdsConstants.adsFolder
      );

    }

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

    return result;
  }

}