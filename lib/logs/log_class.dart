import 'dart:io';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:admin_dvij/logs/action_class.dart';
import 'package:admin_dvij/logs/entity_enum.dart';
import 'package:admin_dvij/logs/log_list_class.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:firebase_database/firebase_database.dart';
import '../constants/database_constants.dart';
import '../database/database_class.dart';
import '../users/admin_user/admin_user_class.dart';

class LogCustom implements IEntity{
  DateTime date;
  String id;
  String creatorId;
  LogEntity entity;
  LogAction action;

  LogCustom({
    required this.date,
    required this.id,
    required this.creatorId,
    required this.entity,
    required this.action
  });

  factory LogCustom.empty(){
    return LogCustom(
        date: DateTime.now(),
        id: '',
        creatorId: '',
        entity: LogEntity(entity: EntityEnum.notChosen),
        action: LogAction(action: ActionEnum.create)
    );
  }

  Future<String> createAndPublishLog({
    required String entityId,
    required EntityEnum entityEnum,
    required ActionEnum actionEnum,
    required String creatorId
  }) async {

    String tempCreatorId = creatorId;

    if (creatorId.isEmpty){
      AdminUserClass admin = await AdminUserClass.empty().getCurrentUser();
      tempCreatorId = admin.uid;
    }

    // Делаем запись в лог
    LogCustom log = LogCustom(
        date: DateTime.now(),
        id: entityId,
        creatorId: tempCreatorId,
        entity: LogEntity(entity: entityEnum),
        action: LogAction(action: actionEnum)
    );

    return await log.publishToDb(null);
  }

  factory LogCustom.fromSnapshot({required DataSnapshot snapshot}) {
    return LogCustom(
        date: DateTime.parse(snapshot.child(DatabaseConstants.date).value.toString()),
        id: snapshot.child(DatabaseConstants.id).value.toString(),
        creatorId: snapshot.child(DatabaseConstants.creatorId).value.toString(),
        entity: LogEntity.fromString(entityString: snapshot.child(DatabaseConstants.entity).value.toString()),
        action: LogAction.fromString(actionString: snapshot.child(DatabaseConstants.action).value.toString())
    );
  }

  factory LogCustom.fromJson({required Map<String, dynamic> json}) {
    return LogCustom(
        date: DateTime.parse(json[DatabaseConstants.date] ?? ''),
        id: json[DatabaseConstants.id] ?? '',
        creatorId: json[DatabaseConstants.creatorId] ?? '',
        entity: LogEntity.fromString(entityString: json[DatabaseConstants.entity] ?? ''),
        action: LogAction.fromString(actionString: json[DatabaseConstants.action] ?? '')
    );
  }

  @override
  Future<String> deleteFromDb() async{
    return SystemConstants.deletingImpossible;
  }

  @override
  Map<String, dynamic> getMap() {
    return <String, dynamic> {
      DatabaseConstants.date: date.toString(),
      DatabaseConstants.id: id,
      DatabaseConstants.creatorId: creatorId,
      DatabaseConstants.entity: entity.toString(),
      DatabaseConstants.action: action.toString()
    };
  }

  @override
  Future<String> publishToDb(File? imageFile) async {
    SystemMethodsClass sm = SystemMethodsClass();
    DatabaseClass db = DatabaseClass();

    // Если Id не задан
    if (id == '') {
      // Генерируем ID
      String? idCity = db.generateKey();

      // Если ID по какой то причине не сгенерировался
      // генерируем вручную
      id = idCity ?? 'noId_${date.toString()}';
    }

    String path = '${DatabaseConstants.logs}/${date.year}/${sm.formatMonthToEnglish(date)}/${sm.formatDayWithDashes(date)}/$id';

    Map <String, dynamic> logData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, logData);

    } else {

      result = await db.publishToDBForWindows(path, logData);

    }

    if (result == SystemConstants.successConst) {
      // Если результат успешный, добавляем в общий сохраненный список

      LogListClass logListClass = LogListClass();
      logListClass.addToCurrentDownloadedList(this);

    }

    return result;
  }

}