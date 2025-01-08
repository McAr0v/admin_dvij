import 'dart:io';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/feedback/feedback_list_class.dart';
import 'package:admin_dvij/feedback/feedback_message.dart';
import 'package:admin_dvij/feedback/feedback_status.dart';
import 'package:admin_dvij/feedback/feedback_topic.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/database_constants.dart';
import '../constants/feedback_constants.dart';
import '../constants/system_constants.dart';
import '../database/database_class.dart';
import '../users/simple_users/simple_user.dart';

class FeedbackCustom implements IEntity{
  String id;
  String userId;
  DateTime createDate;
  DateTime? finishDate;
  FeedbackStatus status;
  FeedbackTopic topic;
  List<FeedbackMessage> messages;

  FeedbackCustom({
    required this.id,
    required this.createDate,
    required this.userId,
    this.finishDate,
    required this.status,
    required this.topic,
    required this.messages
  });

  factory FeedbackCustom.empty(){
    return FeedbackCustom(
        id: '',
        userId: '',
        createDate: DateTime.now(),
        status: FeedbackStatus(status: FeedbackStatusEnum.received),
        topic: FeedbackTopic(),
        messages: []
    );
  }

  factory FeedbackCustom.fromSnapshot({required DataSnapshot snapshot}){

    DataSnapshot messageInfoFolder = snapshot.child(DatabaseConstants.messageInfo);
    DataSnapshot messagesFolder = snapshot.child(DatabaseConstants.messages);
    String finishDateValue = messageInfoFolder.child(DatabaseConstants.finishDate).value.toString();

    return FeedbackCustom(
        id: messageInfoFolder.child(DatabaseConstants.id).value.toString(),
        userId: messageInfoFolder.child(DatabaseConstants.userId).value.toString(),
        createDate: DateTime.parse(messageInfoFolder.child(DatabaseConstants.createDate).value.toString()),
        finishDate: finishDateValue.isNotEmpty ? DateTime.parse(finishDateValue) : null,
        status: FeedbackStatus.fromString(status: messageInfoFolder.child(DatabaseConstants.status).value.toString()),
        topic: FeedbackTopic.fromString(topic: messageInfoFolder.child(DatabaseConstants.topic).value.toString()),
        messages: FeedbackCustom.empty().getMessagesFromSnapshotOrJson(snapshot: messagesFolder)
    );
  }

  factory FeedbackCustom.fromJson({required Map<String, dynamic> json}) {

    Map<String, dynamic> messageInfoFolder = json[DatabaseConstants.messageInfo];
    Map<String, dynamic> messagesFolder = json[DatabaseConstants.messages];
    String finishDateValue = messageInfoFolder[DatabaseConstants.finishDate] ?? '';

    return FeedbackCustom(
        id: messageInfoFolder[DatabaseConstants.id] ?? '',
        createDate: DateTime.parse(messageInfoFolder[DatabaseConstants.createDate] ?? ''),
        finishDate: finishDateValue.isNotEmpty ? DateTime.parse(finishDateValue) : null,
        userId: messageInfoFolder[DatabaseConstants.userId] ?? '',
        status: FeedbackStatus.fromString(status: messageInfoFolder[DatabaseConstants.status] ?? ''),
        topic: FeedbackTopic.fromString(topic: messageInfoFolder[DatabaseConstants.topic] ?? ''),
        messages: FeedbackCustom.empty().getMessagesFromSnapshotOrJson(json: messagesFolder)
    );
  }

  List<FeedbackMessage> getMessagesFromSnapshotOrJson({DataSnapshot? snapshot, Map<String, dynamic>? json}) {
    List<FeedbackMessage> returnedList = [];

    if (snapshot != null && snapshot.exists) {
      for(DataSnapshot idFolder in snapshot.children){
        FeedbackMessage tempEntity = FeedbackMessage.fromSnapshot(snapshot: idFolder);
        if (tempEntity.id.isNotEmpty){
          returnedList.add(tempEntity);
        }
      }
    } else if (json != null) {
      json.forEach((key, idFolders) {
        returnedList.add(FeedbackMessage.fromJson(json: idFolders));
      });
    }
    return returnedList;
  }

  @override
  Future<String> deleteFromDb() async {

    DatabaseClass db = DatabaseClass();

    String path = '${FeedbackConstants.feedbackPath}/$userId/$id';

    String result = '';

    if (!Platform.isWindows){
      result =  await db.deleteFromDb(path);
    } else {
      result = await db.deleteFromDbForWindows(path);
    }

    if (result == SystemConstants.successConst) {
      // Если удаление прошло успешно, удаляем из общего списка
      FeedbackListClass feedbackList = FeedbackListClass();
      feedbackList.deleteEntityFromDownloadedList(id);
    }

    return result;
  }

  @override
  Map<String, dynamic> getMap() {
    return <String, dynamic> {
      DatabaseConstants.id: id,
      DatabaseConstants.userId: userId,
      DatabaseConstants.createDate: createDate.toString(),
      DatabaseConstants.finishDate: finishDate != null ? finishDate.toString() : '',
      DatabaseConstants.status: status.toString(),
      DatabaseConstants.topic: topic.toString()
    };
  }

  @override
  Future<String> publishToDb(File? imageFile) async{

    // Todo - если это создание фидбака, то нужно чтобы помимо публикации тела было публикация первого сообщения в основном приложении
    // Так как первое сообщение будет всегда писать пользователь

    DatabaseClass db = DatabaseClass();

    // Если Id не задан
    if (id == '') {
      // Генерируем ID
      String? idFeedback = db.generateKey();

      // Если ID по какой то причине не сгенерировался
      // генерируем вручную
      id = idFeedback ?? 'noId_$createDate';
    }

    String path = '${FeedbackConstants.feedbackPath}/$userId/$id/${DatabaseConstants.messageInfo}';

    Map <String, dynamic> feedbackData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, feedbackData);

    } else {

      result = await db.publishToDBForWindows(path, feedbackData);

    }


    if (result == SystemConstants.successConst) {
      // Если результат успешный, добавляем в общий сохраненный список
      FeedbackListClass feedbackList = FeedbackListClass();
      feedbackList.addToCurrentDownloadedList(this);
    }

    return result;
  }

  Widget getFeedbackWidget(){

    SimpleUsersList simpleUsersList = SimpleUsersList();
    SimpleUser client = simpleUsersList.getEntityFromList(userId);

    return Card(
      child: Padding(
          padding: EdgeInsets.all(20),
        child: Row(
          children: [
            ElementsOfDesign.getAvatar(url: client.avatar),
            Expanded(
              child: Column(
                children: [
                  Text(client.getFullName()),
                ],

              ),
            )
          ],
        ),
      ),
    );
  }

}