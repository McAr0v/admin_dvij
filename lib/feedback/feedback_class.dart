import 'dart:io';
import 'package:admin_dvij/design/app_colors.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/feedback/feedback_list_class.dart';
import 'package:admin_dvij/feedback/feedback_message.dart';
import 'package:admin_dvij/feedback/feedback_status.dart';
import 'package:admin_dvij/feedback/feedback_topic.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:firebase_database/firebase_database.dart';
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

  bool checkBeforeSaving(){

    bool result = true;

    if (id.isEmpty || userId.isEmpty || topic.topic == FeedbackTopicEnum.notChosen) {
      result = false;
    }

    return result;

  }

  bool checkMessagesOnSearchingText(String text){
    bool result = false;
    for (FeedbackMessage message in messages){
      if (message.messageText.toLowerCase().contains(text)) {
        result = true;
        break;
      }
    }
    return result;
  }

  bool checkUserFullNameOnSearchingText(String text){
    SimpleUsersList simpleUsersList = SimpleUsersList();
    bool result = false;
    for (FeedbackMessage message in messages){

      SimpleUser tempUser = simpleUsersList.getEntityFromList(message.userId);

      if (tempUser.getFullName().toLowerCase().contains(text)) {
        result = true;
        break;
      }
    }
    return result;
  }

  factory FeedbackCustom.fromSnapshot({required DataSnapshot snapshot}){

    DataSnapshot messageInfoFolder = snapshot.child(DatabaseConstants.messageInfo);
    DataSnapshot messagesFolder = snapshot.child(DatabaseConstants.messages);
    String finishDateValue = messageInfoFolder.child(DatabaseConstants.finishDate).value.toString();

    return FeedbackCustom(
        id: messageInfoFolder.child(DatabaseConstants.id).value.toString(),
        userId: messageInfoFolder.child(DatabaseConstants.userId).value.toString(),
        createDate: DateTime.parse(messageInfoFolder.child(DatabaseConstants.createDate).value.toString()),
        finishDate: finishDateValue.isNotEmpty && finishDateValue != SystemConstants.nullConst ? DateTime.parse(finishDateValue) : null,
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

    returnedList.sortFeedbackMessages(false);

    return returnedList;
  }

  @override
  Future<String> deleteFromDb() async {

    DatabaseClass db = DatabaseClass();

    String path = '${FeedbackConstants.feedbackPath}/$userId/$id';

    String result = '';

    for (FeedbackMessage message in messages){
      await message.deleteFromDb();
    }

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

  FeedbackMessage getLastMessage() {
    if (messages.isEmpty) return FeedbackMessage.empty();

    return messages.reduce((latest, message) =>
    message.sendTime.isAfter(latest.sendTime) ? message : latest
    );
  }

  Widget getFeedbackWidget({
    required BuildContext context,
    required VoidCallback onTap,
  }){

    SystemMethodsClass sm = SystemMethodsClass();
    SimpleUsersList simpleUsersList = SimpleUsersList();
    SimpleUser client = simpleUsersList.getEntityFromList(userId);

    FeedbackMessage lastMessage = getLastMessage();
    SimpleUser sender = simpleUsersList.getEntityFromList(lastMessage.senderId);

    Widget avatar = client.getAvatar(size: 40);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: AppColors.greyOnBackground,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  avatar,
                  const SizedBox(width: 20,),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElementsOfDesign.getTag(context: context, text: status.toString(translate: true)),

                        const SizedBox(height: 10,),

                        Text(
                            topic.toString(translate: true),
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis
                        ),

                        const SizedBox(height: 5,),

                        Text(id, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),),

                        const SizedBox(height: 5,),

                        Text(client.getFullName(), style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),),

                      ],
                    ),
                  ),
                ],
              ),

              Card(
                color: AppColors.greyForCards,
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lastMessage.id.isNotEmpty ? lastMessage.messageText : SystemConstants.noMessages,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.greyText,
                        ),
                        textAlign: TextAlign.start,
                        softWrap: false,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        '${sender.getFullName()}, ${sm.formatDateTimeToHumanViewWithClock(lastMessage.sendTime)}',
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                        textAlign: TextAlign.end,
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

extension SortFeedbackMessageListExtension on List<FeedbackMessage> {

  void sortFeedbackMessages(bool order) {
    if (order) {
      sort((a, b) => a.sendTime.compareTo(b.sendTime));
    } else {
      sort((a, b) => b.sendTime.compareTo(a.sendTime));
    }
  }

}