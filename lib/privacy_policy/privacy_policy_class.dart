import 'dart:io';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:admin_dvij/privacy_policy/privacy_policy_list_class.dart';
import 'package:admin_dvij/system_methods/dates_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import '../constants/system_constants.dart';
import '../database/database_class.dart';

class PrivacyPolicyClass implements IEntity{

  DateTime date;
  String startText;
  String dataCollection;
  String dataUsage;
  String transferData;
  String dataSecurity;
  String yourRights;
  String changes;
  String contacts;

  PrivacyPolicyClass({
    required this.date,
    required this.startText,
    required this.dataCollection,
    required this.dataUsage,
    required this.transferData,
    required this.dataSecurity,
    required this.yourRights,
    required this.changes,
    required this.contacts
  });

  factory PrivacyPolicyClass.empty(){
    return PrivacyPolicyClass(
        date: DateTime.now(),
        startText: '',
        dataCollection: '',
        dataUsage: '',
        transferData: '',
        dataSecurity: '',
        yourRights: '',
        changes: '',
        contacts: ''
    );
  }

  factory PrivacyPolicyClass.fromSnapshot({required DataSnapshot snapshot}){
    return PrivacyPolicyClass(
        date: DateTime.parse(snapshot.child('publishDate').value.toString()),
        startText: snapshot.child('startText').value.toString(),
        dataCollection: snapshot.child('dataCollection').value.toString(),
        dataUsage: snapshot.child('dataUsage').value.toString(),
        transferData: snapshot.child('transferData').value.toString(),
        dataSecurity: snapshot.child('dataSecurity').value.toString(),
        yourRights: snapshot.child('yourRights').value.toString(),
        changes: snapshot.child('changes').value.toString(),
        contacts: snapshot.child('contacts').value.toString()
    );
  }

  factory PrivacyPolicyClass.fromJson({required Map<String, dynamic> json}){
    return PrivacyPolicyClass(
        date: DateTime.parse(json['publishDate'] ?? ''),
        startText: json['startText'] ?? '',
        dataCollection: json['dataCollection'] ?? '',
        dataUsage: json['dataUsage'] ?? '',
        transferData: json['transferData'] ?? '',
        dataSecurity: json['dataSecurity'] ?? '',
        yourRights: json['yourRights'] ?? '',
        changes: json['changes'] ?? '',
        contacts: json['contacts'] ?? ''
    );
  }

  @override
  Future<String> deleteFromDb() async {

    DatabaseClass db = DatabaseClass();

    String path = 'privacy_policy/${getFolderId()}';

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
      'date': date.toString(),
      'startText': startText,
      'dataCollection': dataCollection,
      'dataUsage': dataUsage,
      'transferData': transferData,
      'dataSecurity': dataSecurity,
      'yourRights': yourRights,
      'changes': changes,
      'contacts': contacts,
    };
  }

  String getFolderId(){
    DateMethods dm = DateMethods();
    return '${date.year}-${dm.formatTimeOrDateWithZero(date.month)}-${dm.formatTimeOrDateWithZero(date.day)}';
  }

  @override
  Future<String> publishToDb(File? imageFile) async {

    DatabaseClass db = DatabaseClass();

    String path = 'privacy_policy/${getFolderId()}';

    Map <String, dynamic> data = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, data);

    } else {

      result = await db.publishToDBForWindows(path, data);

    }

    if (result == SystemConstants.successConst) {
      // Если результат успешный, добавляем в общий сохраненный список

      PrivacyPolicyList privacyPolicyList = PrivacyPolicyList();
      privacyPolicyList.addToCurrentDownloadedList(this);

    }

    return result;
  }

}