import 'dart:io';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../constants/database_constants.dart';
import '../../database/database_class.dart';

class AdPrice {

  int mainFirstSlot;
  int mainSecondSlot;
  int mainThirdSlot;
  int eventsFirstSlot;
  int eventsSecondSlot;
  int eventsThirdSlot;
  int placesFirstSlot;
  int placesSecondSlot;
  int placesThirdSlot;
  int promosFirstSlot;
  int promosSecondSlot;
  int promosThirdSlot;


  AdPrice({
    required this.mainFirstSlot,
    required this.mainSecondSlot,
    required this.mainThirdSlot,
    required this.eventsFirstSlot,
    required this.eventsSecondSlot,
    required this.eventsThirdSlot,
    required this.placesFirstSlot,
    required this.placesSecondSlot,
    required this.placesThirdSlot,
    required this.promosFirstSlot,
    required this.promosSecondSlot,
    required this.promosThirdSlot,
  });

  factory AdPrice.empty(){
    return AdPrice(
        mainFirstSlot: 0,
        mainSecondSlot: 0,
        mainThirdSlot: 0,
        eventsFirstSlot: 0,
        eventsSecondSlot: 0,
        eventsThirdSlot: 0,
        placesFirstSlot: 0,
        placesSecondSlot: 0,
        placesThirdSlot: 0,
        promosFirstSlot: 0,
        promosSecondSlot: 0,
        promosThirdSlot: 0
    );
  }

  factory AdPrice.fromSnapshot({required DataSnapshot snapshot}){
    return AdPrice(
        mainFirstSlot: int.tryParse(snapshot.child(DatabaseConstants.mainFirstSlot).value.toString()) ?? 0,
        mainSecondSlot: int.tryParse(snapshot.child(DatabaseConstants.mainSecondSlot).value.toString()) ?? 0,
        mainThirdSlot: int.tryParse(snapshot.child(DatabaseConstants.mainThirdSlot).value.toString()) ?? 0,
        eventsFirstSlot: int.tryParse(snapshot.child(DatabaseConstants.eventsFirstSlot).value.toString()) ?? 0,
        eventsSecondSlot: int.tryParse(snapshot.child(DatabaseConstants.eventsSecondSlot).value.toString()) ?? 0,
        eventsThirdSlot: int.tryParse(snapshot.child(DatabaseConstants.eventsThirdSlot).value.toString()) ?? 0,
        placesFirstSlot: int.tryParse(snapshot.child(DatabaseConstants.placesFirstSlot).value.toString()) ?? 0,
        placesSecondSlot: int.tryParse(snapshot.child(DatabaseConstants.placesSecondSlot).value.toString()) ?? 0,
        placesThirdSlot: int.tryParse(snapshot.child(DatabaseConstants.placesThirdSlot).value.toString()) ?? 0,
        promosFirstSlot: int.tryParse(snapshot.child(DatabaseConstants.promosFirstSlot).value.toString()) ?? 0,
        promosSecondSlot: int.tryParse(snapshot.child(DatabaseConstants.promosSecondSlot).value.toString()) ?? 0,
        promosThirdSlot: int.tryParse(snapshot.child(DatabaseConstants.promosThirdSlot).value.toString()) ?? 0
    );
  }

  factory AdPrice.fromJson({required Map<String, dynamic> json}){
    return AdPrice(
        mainFirstSlot: int.tryParse(json[DatabaseConstants.mainFirstSlot]) ?? 0,
        mainSecondSlot: int.tryParse(json[DatabaseConstants.mainSecondSlot]) ?? 0,
        mainThirdSlot: int.tryParse(json[DatabaseConstants.mainThirdSlot]) ?? 0,
        eventsFirstSlot: int.tryParse(json[DatabaseConstants.eventsFirstSlot]) ?? 0,
        eventsSecondSlot: int.tryParse(json[DatabaseConstants.eventsSecondSlot]) ?? 0,
        eventsThirdSlot: int.tryParse(json[DatabaseConstants.eventsThirdSlot]) ?? 0,
        placesFirstSlot: int.tryParse(json[DatabaseConstants.placesFirstSlot]) ?? 0,
        placesSecondSlot: int.tryParse(json[DatabaseConstants.placesSecondSlot]) ?? 0,
        placesThirdSlot: int.tryParse(json[DatabaseConstants.placesThirdSlot]) ?? 0,
        promosFirstSlot: int.tryParse(json[DatabaseConstants.promosFirstSlot]) ?? 0,
        promosSecondSlot: int.tryParse(json[DatabaseConstants.promosSecondSlot]) ?? 0,
        promosThirdSlot: int.tryParse(json[DatabaseConstants.promosThirdSlot]) ?? 0
    );
  }

  Map<String, String> getMap() {

    SystemMethodsClass sm = SystemMethodsClass();

    return <String, String> {
      DatabaseConstants.mainFirstSlot: mainFirstSlot.toString(),
      DatabaseConstants.mainSecondSlot: mainSecondSlot.toString(),
      DatabaseConstants.mainThirdSlot: mainThirdSlot.toString(),
      DatabaseConstants.eventsFirstSlot: eventsFirstSlot.toString(),
      DatabaseConstants.eventsSecondSlot: eventsSecondSlot.toString(),
      DatabaseConstants.eventsThirdSlot: eventsThirdSlot.toString(),
      DatabaseConstants.placesFirstSlot: placesFirstSlot.toString(),
      DatabaseConstants.placesSecondSlot: placesSecondSlot.toString(),
      DatabaseConstants.placesThirdSlot: placesThirdSlot.toString(),
      DatabaseConstants.promosFirstSlot: promosFirstSlot.toString(),
      DatabaseConstants.promosSecondSlot: promosSecondSlot.toString(),
      DatabaseConstants.promosThirdSlot: promosThirdSlot.toString(),

      DatabaseConstants.mainFirstSlotTwoWeeks: sm.applyDiscountAndRoundUp(mainFirstSlot, 10).toString(),
      DatabaseConstants.mainSecondSlotTwoWeeks: sm.applyDiscountAndRoundUp(mainSecondSlot, 10).toString(),
      DatabaseConstants.mainThirdSlotTwoWeeks: sm.applyDiscountAndRoundUp(mainThirdSlot, 10).toString(),
      DatabaseConstants.eventsFirstSlotTwoWeeks: sm.applyDiscountAndRoundUp(eventsFirstSlot, 10).toString(),
      DatabaseConstants.eventsSecondSlotTwoWeeks: sm.applyDiscountAndRoundUp(eventsSecondSlot, 10).toString(),
      DatabaseConstants.eventsThirdSlotTwoWeeks: sm.applyDiscountAndRoundUp(eventsThirdSlot, 10).toString(),
      DatabaseConstants.placesFirstSlotTwoWeeks: sm.applyDiscountAndRoundUp(placesFirstSlot, 10).toString(),
      DatabaseConstants.placesSecondSlotTwoWeeks: sm.applyDiscountAndRoundUp(placesSecondSlot, 10).toString(),
      DatabaseConstants.placesThirdSlotTwoWeeks: sm.applyDiscountAndRoundUp(placesThirdSlot, 10).toString(),
      DatabaseConstants.promosFirstSlotTwoWeeks: sm.applyDiscountAndRoundUp(promosFirstSlot, 10).toString(),
      DatabaseConstants.promosSecondSlotTwoWeeks: sm.applyDiscountAndRoundUp(promosSecondSlot, 10).toString(),
      DatabaseConstants.promosThirdSlotTwoWeeks: sm.applyDiscountAndRoundUp(promosThirdSlot, 10).toString(),

      DatabaseConstants.mainFirstSlotFourWeeks: sm.applyDiscountAndRoundUp(mainFirstSlot, 20).toString(),
      DatabaseConstants.mainSecondSlotFourWeeks: sm.applyDiscountAndRoundUp(mainSecondSlot, 20).toString(),
      DatabaseConstants.mainThirdSlotFourWeeks: sm.applyDiscountAndRoundUp(mainThirdSlot, 20).toString(),
      DatabaseConstants.eventsFirstSlotFourWeeks: sm.applyDiscountAndRoundUp(eventsFirstSlot, 20).toString(),
      DatabaseConstants.eventsSecondSlotFourWeeks: sm.applyDiscountAndRoundUp(eventsSecondSlot, 20).toString(),
      DatabaseConstants.eventsThirdSlotFourWeeks: sm.applyDiscountAndRoundUp(eventsThirdSlot, 20).toString(),
      DatabaseConstants.placesFirstSlotFourWeeks: sm.applyDiscountAndRoundUp(placesFirstSlot, 20).toString(),
      DatabaseConstants.placesSecondSlotFourWeeks: sm.applyDiscountAndRoundUp(placesSecondSlot, 20).toString(),
      DatabaseConstants.placesThirdSlotFourWeeks: sm.applyDiscountAndRoundUp(placesThirdSlot, 20).toString(),
      DatabaseConstants.promosFirstSlotFourWeeks: sm.applyDiscountAndRoundUp(promosFirstSlot, 20).toString(),
      DatabaseConstants.promosSecondSlotFourWeeks: sm.applyDiscountAndRoundUp(promosSecondSlot, 20).toString(),
      DatabaseConstants.promosThirdSlotFourWeeks: sm.applyDiscountAndRoundUp(promosThirdSlot, 20).toString(),
    };
  }

  Future<String> publishToDb() async{

    DatabaseClass db = DatabaseClass();

    String path = DatabaseConstants.adPriceFolder;

    Map <String, dynamic> eventData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, eventData);

    } else {

      result = await db.publishToDBForWindows(path, eventData);

    }

    return result;
  }

  Future<AdPrice> getFromDb()async {
    DatabaseClass database = DatabaseClass();

    const String path = DatabaseConstants.adPriceFolder;

    // Загрузка если платформа не Windows
    if (!Platform.isWindows){
      DataSnapshot? snapshot = await database.getInfoFromDb(path);

      if (snapshot != null && snapshot.exists) {
        return AdPrice.fromSnapshot(snapshot: snapshot);
      }

    } else {

      // Загрузка если Windows

      dynamic data = await database.getInfoFromDbForWindows(path);

      if (data != null){
        return AdPrice.fromJson(json: data);
      }
    }

    return AdPrice.empty();

  }


}