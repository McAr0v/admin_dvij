import 'dart:io';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import '../constants/ads_constants.dart';
import '../constants/database_constants.dart';
import '../database/database_class.dart';
import 'ad_class.dart';
import 'ads_enums_class/ad_index.dart';
import 'ads_enums_class/ad_location.dart';

class AdForMainApp implements IEntity{
  String id;
  String headline;
  String desc;
  String url;
  String imageUrl;
  DateTime startDate;
  DateTime endDate;
  AdLocation location;
  AdIndex adIndex;

  AdForMainApp({
    required this.id,
    required this.headline,
    required this.desc,
    required this.url,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.adIndex,
  });

  factory AdForMainApp.fromAdClass({required AdClass adminAd}){
    return AdForMainApp(
        id: adminAd.id,
        headline: adminAd.headline,
        desc: adminAd.desc,
        url: adminAd.url,
        imageUrl: adminAd.imageUrl,
        startDate: adminAd.startDate,
        endDate: adminAd.endDate,
        location: adminAd.location,
        adIndex: adminAd.adIndex,
    );
  }

  @override
  Future<String> deleteFromDb() async{
    DatabaseClass db = DatabaseClass();

    String path = '${AdsConstants.adsForMainAppFolder}/${location.toString()}/${adIndex.toString()}/$id/';

    String result = '';

    if (!Platform.isWindows){
      result =  await db.deleteFromDb(path);
    } else {
      result = await db.deleteFromDbForWindows(path);
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
    };
  }

  @override
  Future<String> publishToDb(File? imageFile) async{
    DatabaseClass db = DatabaseClass();

    // Если Id не задан
    if (id == '') {
      // Генерируем ID
      String? adId = db.generateKey();

      // Если ID по какой то причине не сгенерировался
      // генерируем вручную
      id = adId ?? 'noID_$headline';
    }

    String path = '${AdsConstants.adsForMainAppFolder}/${location.toString()}/${adIndex.toString()}/$id/';

    Map <String, dynamic> userData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, userData);

    } else {

      result = await db.publishToDBForWindows(path, userData);

    }

    return result;
  }

}