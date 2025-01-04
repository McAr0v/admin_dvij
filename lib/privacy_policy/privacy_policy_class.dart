import 'dart:io';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:admin_dvij/privacy_policy/privacy_enum.dart';
import 'package:admin_dvij/privacy_policy/privacy_policy_list_class.dart';
import 'package:admin_dvij/system_methods/dates_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import '../constants/system_constants.dart';
import '../database/database_class.dart';

class PrivacyPolicyClass implements IEntity{

  String id;
  DateTime date;
  String startText;
  String dataCollection;
  String dataUsage;
  String transferData;
  String dataSecurity;
  String yourRights;
  String changes;
  String contacts;
  PrivacyStatus status;

  PrivacyPolicyClass({
    required this.id,
    required this.date,
    required this.startText,
    required this.dataCollection,
    required this.dataUsage,
    required this.transferData,
    required this.dataSecurity,
    required this.yourRights,
    required this.changes,
    required this.contacts,
    required this.status
  });

  factory PrivacyPolicyClass.empty(){
    return PrivacyPolicyClass(
        id: '',
        date: DateTime.now(),
        startText: '',
        dataCollection: '',
        dataUsage: '',
        transferData: '',
        dataSecurity: '',
        yourRights: '',
        changes: '',
        contacts: '',
      status: PrivacyStatus()
    );
  }

  factory PrivacyPolicyClass.copyPrivacy({required PrivacyPolicyClass copiedEntity}){
    return PrivacyPolicyClass(
        id: '',
        date: DateTime.now(),
        startText: copiedEntity.startText,
        dataCollection: copiedEntity.dataCollection,
        dataUsage: copiedEntity.dataUsage,
        transferData: copiedEntity.transferData,
        dataSecurity: copiedEntity.dataSecurity,
        yourRights: copiedEntity.yourRights,
        changes: copiedEntity.changes,
        contacts: copiedEntity.contacts,
        status: PrivacyStatus()
    );
  }

  factory PrivacyPolicyClass.fillPrivacy({required PrivacyPolicyClass copiedEntity}){
    return PrivacyPolicyClass(
        id: copiedEntity.id,
        date: copiedEntity.date,
        startText: copiedEntity.startText,
        dataCollection: copiedEntity.dataCollection,
        dataUsage: copiedEntity.dataUsage,
        transferData: copiedEntity.transferData,
        dataSecurity: copiedEntity.dataSecurity,
        yourRights: copiedEntity.yourRights,
        changes: copiedEntity.changes,
        contacts: copiedEntity.contacts,
        status: copiedEntity.status
    );
  }

  factory PrivacyPolicyClass.fromSnapshot({required DataSnapshot snapshot}){
    return PrivacyPolicyClass(
        id: snapshot.child('id').value.toString(),
        date: DateTime.parse(snapshot.child('publishDate').value.toString()),
        startText: snapshot.child('startText').value.toString(),
        dataCollection: snapshot.child('dataCollection').value.toString(),
        dataUsage: snapshot.child('dataUsage').value.toString(),
        transferData: snapshot.child('transferData').value.toString(),
        dataSecurity: snapshot.child('dataSecurity').value.toString(),
        yourRights: snapshot.child('yourRights').value.toString(),
        changes: snapshot.child('changes').value.toString(),
        contacts: snapshot.child('contacts').value.toString(),
      status: PrivacyStatus.fromString(statusString: snapshot.child('status').value.toString())
    );
  }

  factory PrivacyPolicyClass.fromJson({required Map<String, dynamic> json}){
    return PrivacyPolicyClass(
        id:  json['id'] ?? '',
        date: DateTime.parse(json['publishDate'] ?? ''),
        startText: json['startText'] ?? '',
        dataCollection: json['dataCollection'] ?? '',
        dataUsage: json['dataUsage'] ?? '',
        transferData: json['transferData'] ?? '',
        dataSecurity: json['dataSecurity'] ?? '',
        yourRights: json['yourRights'] ?? '',
        changes: json['changes'] ?? '',
        contacts: json['contacts'] ?? '',
        status: PrivacyStatus.fromString(statusString: json['status'] ?? '')
    );
  }

  bool isActive (){
    return status.privacyEnum == PrivacyEnum.active;
  }

  String checkEmptyFieldsInPrivacy(){
    if (startText.isEmpty){
      return 'No startText';
    }

    if (dataCollection.isEmpty){
      return 'No datacollection';
    }

    if (dataUsage.isEmpty) {
      return 'no DataUsage';
    }

    if (transferData.isEmpty) {
      return 'no transferData';
    }
    if (dataSecurity.isEmpty) {
      return 'no dataSecurity';
    }
    if (yourRights.isEmpty) {
      return 'no yourRights';
    }
    if (changes.isEmpty) {
      return 'no changes';
    }
    if (contacts.isEmpty) {
      return 'no contacts';
    }

    return SystemConstants.successConst;
  }

  @override
  Future<String> deleteFromDb() async {

    DatabaseClass db = DatabaseClass();

    String path = 'privacy_policy/$id';

    String result = '';

    if (!Platform.isWindows){

      result =  await db.deleteFromDb(path);

    } else {

      result = await db.deleteFromDbForWindows(path);

    }

    if (result == SystemConstants.successConst) {
      // Если удаление прошло успешно, удаляем из общего списка
      PrivacyPolicyList privacyPolicyList = PrivacyPolicyList();
      privacyPolicyList.deleteEntityFromDownloadedList(getFolderId());
    }

    return result;
  }

  @override
  Map<String, dynamic> getMap() {
    return <String, dynamic> {
      'id': id,
      'publishDate': date.toString(),
      'startText': startText,
      'dataCollection': dataCollection,
      'dataUsage': dataUsage,
      'transferData': transferData,
      'dataSecurity': dataSecurity,
      'yourRights': yourRights,
      'changes': changes,
      'contacts': contacts,
      'status': status.toString()
    };
  }

  String getFolderId(){
    DateMethods dm = DateMethods();
    return '${date.year}-${dm.formatTimeOrDateWithZero(date.month)}-${dm.formatTimeOrDateWithZero(date.day)}';
  }

  @override
  Future<String> publishToDb(File? imageFile) async {

    DatabaseClass db = DatabaseClass();

    // Если Id не задан
    if (id == '') {
      // Генерируем ID
      String? idPrivacy = db.generateKey();

      // Если ID по какой то причине не сгенерировался
      // генерируем вручную
      id = idPrivacy ?? 'noId_${getFolderId()}';
    }

    String activePath = 'privacy_policy_active';

    String path = 'privacy_policy/$id';

    Map <String, dynamic> data = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, data);

      // Если это активное, то перезаписываем предыдущее активное в БД
      // Так как только 1 версия может быть активной

      if (isActive()) {
        result = await db.publishToDB(activePath, data);
      }

    } else {

      result = await db.publishToDBForWindows(path, data);

      // Если это активное, то перезаписываем предыдущее активное в БД
      // Так как только 1 версия может быть активной

      if (isActive()) {
        result = await db.publishToDBForWindows(activePath, data);
      }

    }

    if (result == SystemConstants.successConst) {
      // Если результат успешный, добавляем в общий сохраненный список

      PrivacyPolicyList privacyPolicyList = PrivacyPolicyList();

      // Если это объявление активное, деактивируем прошлые активные
      if (isActive()) {
        privacyPolicyList.deactivatedLastActivePrivacy(currentActiveId: id);
      }
      privacyPolicyList.addToCurrentDownloadedList(this);

    }

    return result;
  }

}